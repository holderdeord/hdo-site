class PromisesController < ApplicationController
  hdo_caches_page :index

  def index
    @categories = Category.where(:main => true).includes(:children)
    @parties    = Party.order(:name)
 end

  protected

  def find_promise
    @promise = Promise.find(params[:id])
  end
end
