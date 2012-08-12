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
    @promises_by_party = Category.find(params[:id]).promises.group_by(&:party_id)
    render 'promises', :layout => false
  end


end
