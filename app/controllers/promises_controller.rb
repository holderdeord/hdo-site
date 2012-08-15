class PromisesController < ApplicationController
  caches_page :index

  def index
    @categories = Category.where(:main => true)
    @parties = Party.order(:name)
  end

  protected

  def find_promise
    @promise = Promise.find(params[:id])
  end
end
