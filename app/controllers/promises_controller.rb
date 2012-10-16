class PromisesController < ApplicationController
  caches_page :index

  def index
    @categories       = Category.where(:main => true).includes(:children)
    @parties          = Party.order(:name)
    # @government_slugs = @parties.select(&:in_government?).map(&:slug).join(",")
    @government_slug = "government"
  end

  protected

  def find_promise
    @promise = Promise.find(params[:id])
  end
end
