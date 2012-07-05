class HomeController < ApplicationController
  caches_page :index, :press

  def index
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
  end

  def press
  end

  def login_status
    render layout: false
  end
end
