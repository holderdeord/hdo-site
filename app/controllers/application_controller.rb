class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  def self.hdo_caches_page(*actions)
    before_filter :set_default_expiry, only: actions
  end

  def self.force_fastly_ssl(options = {})
    return unless AppConfig.ssl_enabled && AppConfig.ssl_host

    before_filter(options) do
      if request.env['HTTP_X_IS_SSL'] != 'yes'
        flash.keep if respond_to?(:flash)
        redirect_to protocol: 'https://', status: :moved_permanently, host: AppConfig.ssl_host, params: request.query_parameters
      end
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
