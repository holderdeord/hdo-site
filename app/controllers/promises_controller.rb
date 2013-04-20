class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 30

  def index
    @categories = Category.where(:main => true).includes(:children)
    @parties    = Party.order(:name)
    @category_id = params[:category_id]
    @subcategory_id = params[:subcategory_id]
    @party_slug = params[:party_slug]
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

    if @subcategory_id
      @promises = Category.find(@subcategory_id).promises
    elsif @category_id
      @promises = Category.find(@category_id).promises
    end

    if @party_slug && @party_slug == "government"
      parties = Party.in_government
      @promises = @promises.select { |p| (p.parties - parties).empty? }
    elsif @party_slug
      party = Party.find(@party_slug)
      @promises = @promises.select { |p| p.parties.include? party }
    end

    @promises = @promises.paginate(:page => params[:page], :per_page => DEFAULT_PER_PAGE)

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @promises }
      format.xml  { render xml:  @promises }
    end
  end
end
