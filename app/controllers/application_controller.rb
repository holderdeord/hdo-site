class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  protected

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


end
