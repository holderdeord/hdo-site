class ApplicationController < ActionController::Base
  protect_from_forgery

  # FIXME: just for demo purposes - this switches the local globally (i.e across sessions)
  before_filter :set_locale

  def set_locale
    unless [nil, I18n.locale].include? params[:locale]
      I18n.locale = params[:locale]
    end
  end
end
