class PromisesController < ApplicationController
  caches_page :index

  def index
    @categories       = Category.where(:main => true).includes(:children)
    @parties          = Party.order(:name)
    @page_title       = Promise.model_name.human(count: 2).capitalize
 end

  protected

  def find_promise
    @promise = Promise.find(params[:id])
  end
end
