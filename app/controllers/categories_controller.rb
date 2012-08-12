class CategoriesController < ApplicationController
  caches_page :index, :show

  def index
    @categories = Category.includes(:children).all(:order => :name)

    respond_to do |format|
      format.html
      format.json { render json: @categories }
      format.xml  { render xml:  @categories }
    end
  end

  def show
    @category = Category.includes(:issues).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @category }
      format.xml  { render xml:  @category }
    end
  end

  def promises
    promises = Category.find(params[:id]).promises

    if params[:party]
      promises = promises.includes(:party).
                                  where("parties.slug = ?", params[:party])
    end

    @promises_by_party = promises.group_by(&:party);

    render :layout => false
  end


end
