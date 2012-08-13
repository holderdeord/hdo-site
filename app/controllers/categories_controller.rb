class CategoriesController < ApplicationController
  caches_page :index, :show, :promises

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
    category_id = params[:id] # can't pass a slug here becuase of parent_id in the select below.
    promises    = Promise.includes(:categories, :party).where("categories.id = ? or categories.parent_id = ?", category_id, category_id)

    if params[:party]
      promises = promises.where("parties.slug = ?", params[:party])
    else
      #  TODO: extract to scope
      promises = promises.sort_by { |e| [e.party.in_government? ? 0 : 1, e.party.name]}
    end

    @promises_by_party = promises.group_by(&:party);

    render :layout => false
  end


end
