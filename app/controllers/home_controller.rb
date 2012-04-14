class HomeController < ApplicationController
  caches_page :index, :about

  def index
  end

  def about
  end
end
