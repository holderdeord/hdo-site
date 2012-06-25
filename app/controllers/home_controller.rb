class HomeController < ApplicationController
  caches_page :index, :about

  def index
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
  end
end
