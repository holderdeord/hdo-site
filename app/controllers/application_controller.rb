class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :abilities, :can?

  protected

  def abilities
    @abilities ||= Six.new
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def xhr_only(&blk)
    if request.xhr?
      yield
    else
      head :not_acceptable
    end
  end

end
