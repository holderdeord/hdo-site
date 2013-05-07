class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 100

  def index
    @categories  = Category.where(main: true).includes(:children)
    @category    = @categories.find(params[:category_id]) if params[:category_id].present?
    @subcategory = Category.find(params[:subcategory_id]) if params[:subcategory_id].present?
    @parties     = Party.order(:name)
    @party       = @parties.find(params[:party_slug]) if params[:party_slug].present?

    if @subcategory
      @promises = @subcategory.promises
    elsif @category
      @promises = @category.all_promises
    else
      @promises = Promise
    end

    if @party
      @promises = @promises.joins(:parties).where('parties.id' => @party.id)
    else
      # Pull request https://github.com/rails/rails/pull/6792
      @promises = @promises.joins(:parties).order("parties.id").select("parties.id, promises.*")
    end

    @promises = @promises.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
  end

  def show
    @promise = Promise.find(params[:id])
  end

end
