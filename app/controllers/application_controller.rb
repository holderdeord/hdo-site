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

end
