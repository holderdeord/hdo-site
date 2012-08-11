class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :parties

  private

  def parties
    @parties ||= Party.order(:name)
  end
end
