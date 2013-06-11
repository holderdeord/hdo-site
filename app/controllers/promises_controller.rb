class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  DEFAULT_PER_PAGE = 20

  def index
    fetch_shared

    @category    = @categories.find(params[:category_id]) if params[:category_id].present?
    @subcategory = Category.find(params[:subcategory_id]) if params[:subcategory_id].present?
    @party       = @parties.find(params[:party_slug]) if params[:party_slug].present?
    @period      = params[:period].present? ? ParliamentPeriod.find_by_external_id(params[:period]) : @parliament_periods.last

    # watch out for rails bug: https://github.com/rails/rails/pull/6792
    @promises = @period ? @period.promises : Promise

    filter_and_paginate
  end

  def show
    fetch_shared

    @promise  = Promise.find(params[:id])

    @period   = @promise.parliament_period
    @promises = @period.promises

    @category = @promise.main_category
    @party    = @promise.parties.first

    filter_and_paginate
    @promises = @promises.where('promises.id != ?', @promise.id)

    render :index
  end

  private

  def fetch_shared
    @categories         = Category.where(main: true).includes(:children).order(:name)
    @parties            = Party.order(:name)
    @parliament_periods = Promise.parliament_periods.order(:start_date)
  end

  def filter_and_paginate
    if @subcategory
      @promises = @promises.joins(:categories).where('categories.id' => @subcategory.id)
    elsif @category
      @promises = @promises.joins(:categories).where("categories.id = ? or categories.parent_id = ?", @category.id, @category.id)
    end

    @promises = @promises.includes(:parties)

    if @party
      # TODO: for some reason, this query makes promise.parties (in the view)
      # return only the selected party..
      @promises = @promises.where('parties.id' => [@party])
    else
      @promises = @promises.order('parties.id')
    end

    @promises = @promises.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
  end
end
