class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  #
  # beta has no varnish in front, but the new production servers do.
  # this helps us with the transition
  #

  def self.hdo_caches_page(*actions)
    if AppConfig.beta?
      caches_page(*actions, if: -> { can_cache? })
    else
      before_filter :set_default_expiry, only: actions
    end
  end

  protected

  def set_default_expiry
    if can_cache?
      expires_in 5.minutes, public: true
    end
  end

  def can_cache?
    flash.empty? && current_user.nil?
  end

  def xhr_only(&blk)
    if request.xhr?
      yield
    else
      head :not_acceptable
    end
  end

  def normalize_blanks(attrs)
    attrs.dup.each do |k,v|
      attrs[k] = nil if v.blank?
    end

    attrs
  end

  def assert_feature(key)
    unless AppConfig["#{key}_enabled"]
      render status: 403, text: "#{key} not enabled"
    end
  end

  def render_not_found
    render file: 'public/404', formats: [:html], layout: false, status: 404
  end

end
