class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 20

  def index
    fetch_shared

    @category    = @categories.find(params[:category_id]) if params[:category_id].present?
    @subcategory = Category.find(params[:subcategory_id]) if params[:subcategory_id].present?
    @promisor    = find_promisor if params[:promisor].present?
    @period      = params[:period].present? ? ParliamentPeriod.find_by_external_id(params[:period]) : @parliament_periods.last

    if @period
      # TODO: this can be optimized
      # @parties     = @parties.select { |party| party.promises.where(:parliament_period_id => @period).size > 0 }
      @governments = @governments.select { |government| government.promises.where(:parliament_period_id => @period).size > 0 }
      @promises    = @period.promises
    else
      @promises = Promise
    end

    filter_and_paginate
  end

  def show
    fetch_shared

    @promise  = Promise.find(params[:id])

    @period   = @promise.parliament_period
    @promises = @period.promises

    @category = @promise.main_category
    @promisor = @promise.promisor

    filter_and_paginate
    @promises = @promises.where('promises.id != ?', @promise.id)

    render :index
  end

  private

  def fetch_shared
    @categories         = Category.where(main: true).includes(:children).order(:name)
    @parties            = Party.order(:name)
    @governments        = Government.order(:start_date)
    @parliament_periods = Promise.parliament_periods.order(:start_date)
  end

  def filter_and_paginate
    @promisors = @parties + @governments

    if @subcategory
      @promises = @promises.joins(:categories).where('categories.id' => @subcategory.id)
    elsif @category
      @promises = @promises.joins(:categories).where("categories.id = ? or categories.parent_id = ?", @category.id, @category.id)
    end

    # TODO: eager load of polymorphic assocations is suported in Rails 4, so can probably sort by promisor name then.
    @promises = @promises.order(:promisor_type, :promisor_id, :body).uniq
    @promises = @promises.where(:promisor_id => @promisor, :promisor_type => @promisor.class.name) if @promisor

    @promises = @promises.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
  end

  def find_promisor
    id, type = params[:promisor].split(':', 2)

    case type
    when 'Government'
      @governments.find id
    when 'Party'
      @parties.find id
    end
  end
end
