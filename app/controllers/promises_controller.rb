class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 30

  def index
    @categories = Category.where(:main => true).includes(:children)
    @parties    = Party.order(:name)
    render_promises_index()
  end

  def show
    @promise = Promise.find(params[:id])
  end

  protected

  def find_promise
    @promise = Promise.find(params[:id])
  end

  private

  def render_promises_index(opts = {})
    @promises = Promise.all(:order => 'date')

    categoryId = params[:category_id]
    if categoryId
      @promises = Category.find(categoryId).promises
    end

    @promises = @promises.paginate(:page => params[:page], :per_page => DEFAULT_PER_PAGE)

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @promises }
      format.xml  { render xml:  @promises }
    end
  end
end
