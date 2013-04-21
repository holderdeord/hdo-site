class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 30

  def index
    @categories  = Category.where(main: true).includes(:children)
    @category    = @categories.find(params[:category_id]) if params[:category_id].present?
    @subcategory = Category.find(params[:subcategory_id]) if params[:subcategory_id].present?
    @parties     = Party.order(:name)
    @party       = @parties.find(params[:party_slug]) if params[:party_slug].present?

    if @subcategory
      @promises = Category.find(@subcategory.id).promises
    elsif @category
      @promises = @category.all_promises
    else
      @promises = Promise.includes(:parties).order('date')
    end

    if @party
      @promises = @promises.joins(:parties).where('parties.id' => @party.id)
    end

    @promises = @promises.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
  end

  def show
    @promise = Promise.find(params[:id])
  end

end
