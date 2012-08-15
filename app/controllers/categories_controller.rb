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
    @category = Category.includes(:parliament_issues).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @category }
      format.xml  { render xml:  @category }
    end
  end

  def promises
    # TODO: clean this up https://github.com/holderdeord/hdo-site/issues/182

    category_id = params[:id] # can't pass a slug here becuase of parent_id in the select below.
    promises    = Promise.includes(:categories, :parties).where("categories.id = ? or categories.parent_id = ?", category_id, category_id)

    if params[:party]
      if params[:party].include?(",")
        parties = params[:party].split(",")
        promises = promises.where("parties.slug in (?)", parties).select { |e| e.parties.size == parties.size }
      else
        promises = promises.where("parties.slug = ?", params[:party])
      end
    else
      promises = promises.sort_by do |e|
        if e.parties.size == 1 && e.parties.first.in_government?
          [0, e.parties.first.name] # government first
        elsif e.parties.size > 1 && e.parties.all?(&:in_government?)
          [100, ''] # last
        else
          [1, e.parties.first.name]
        end
      end
    end

    @promises_by_parties = promises.group_by { |e| e.parties.to_a }

    render :layout => false
  end


end
