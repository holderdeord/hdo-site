class ApplicationController < ActionController::Base
  include Pundit
  include Hdo::ReadOnly
  protect_from_forgery
  rescue_from Pundit::NotAuthorizedError, with: :policy_not_allowed

  before_filter :force_ssl_redirect if AppConfig.ssl_enabled

  def self.hdo_caches_page(*actions)
    before_filter :set_default_expiry, only: actions
  end

  protected

  # copied from rails 4
  def force_ssl_redirect(host_or_options = nil)
    unless request.ssl?
      options = {
        :protocol => 'https://',
        :host     => request.host,
        :path     => request.fullpath,
        :status   => :moved_permanently
      }

      if host_or_options.is_a?(Hash)
        options.merge!(host_or_options)
      elsif host_or_options
        options.merge!(:host => host_or_options)
      end

      secure_url = ActionDispatch::Http::URL.url_for(options.slice(:protocol, :host, :domain, :subdomain, :port, :path))
      flash.keep if respond_to?(:flash)
      redirect_to secure_url, options.slice(:status, :flash, :alert, :notice)
    end
  end

  #
  # for devise
  #

  def after_sign_in_path_for(model)
    protocol = AppConfig.ssl_enabled ? 'https://' : request.protocol

    case model
    when Representative
      representative_root_url protocol: protocol
    when User
      admin_root_url protocol: protocol
    else
      raise "unknown user model: #{model.inspect}"
    end
  end

  def after_sign_out_path_for(model)
    root_url
  end

  def set_default_expiry
    if can_cache?
      expires_in 5.minutes, public: true
    end
  end

  def can_cache?
    flash.empty? && !signed_in?
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

  def policy_not_allowed
    render file: 'public/422', formats: [:html], layout: false, status: 401
  end

end
