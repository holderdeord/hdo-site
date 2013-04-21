class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 30

  def index
    @categories = Category.where(:main => true).includes(:children)
    @category = @categories.find(params[:category_id]) if params[:category_id].present?
    @subcategory = Category.find(params[:subcategory_id]) if params[:subcategory_id].present?
    @parties    = Party.order(:name)
    @party = @parties.find(params[:party_slug]) if params[:party_slug].present?
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
    @promises = Promise.includes(:issues).all(:order => 'date')

    if @subcategory
      @promises = Category.find(@subcategory.id).promises
    elsif @category
      @promises = @category.all_promises
    end

    if @party && @party.slug == "government"
      parties = Party.in_government
      @promises = @promises.select { |p| (p.parties - parties).empty? }
    elsif @party
      @promises = @promises.select { |p| p.parties.include? @party }
    end

    @promises = @promises.paginate(:page => params[:page], :per_page => DEFAULT_PER_PAGE)

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @promises }
      format.xml  { render xml:  @promises }
    end
  end
end
