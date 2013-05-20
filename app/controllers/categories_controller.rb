class CategoriesController < ApplicationController
  hdo_caches_page :index, :show, :promises

  def index
    @categories = Category.all_with_children
  end

  def show
    @category = Category.includes(:parliament_issues).find(params[:id])
    fresh_when @category, public: can_cache?
  end

end
