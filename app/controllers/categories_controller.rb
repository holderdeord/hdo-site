class CategoriesController < ApplicationController
  hdo_caches_page :index, :show, :promises

  def index
    @categories = Category.all_with_children
  end

  def show
    @category = Category.includes(:parliament_issues).find(params[:id])
    fresh_when @category, public: can_cache?
  end

  def promises
    # TODO: clean this up https://github.com/holderdeord/hdo-site/issues/182

    category_id = params[:id] # can't pass a slug here becuase of parent_id in the select below.
    promises    = Promise.includes(:categories, :parties).where("categories.id = ? or categories.parent_id = ?", category_id, category_id)

    if params[:party]
      if params[:party] == "government"
        slugs = Party.in_government.map { |e| e.slug }
        promises = promises.where("parties.slug in (?)", slugs).select { |e| e.parties.size == slugs.size }
      else
        promises = promises.where("parties.slug = ?", params[:party])
      end
    else
      promises = promises.sort_by do |e|
        if e.parties.size == 1 && e.parties.first.in_government?
          [0, e.parties.first.name] # government first
        elsif e.parties.size > 1 && e.parties == Party.in_government
          [100, ''] # last
        else
          [1, e.parties.first.name]
        end
      end
    end

    @promises_by_parties = promises.group_by { |e| e.parties.to_a }

    render layout: false
  end

  def subcategories
    render json: Category.where(parent_id: params[:id]).to_json(only: :id, methods: :human_name)
  end

end
