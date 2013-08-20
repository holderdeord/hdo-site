class SearchController < ApplicationController
  hdo_caches_page :all, :autocomplete

  TYPE_ORDER = %w[
    issue
    topic
    representative
    parliament_issue
    proposition
    promise
  ]

  def all
    response = Hdo::Search::Searcher.new(params[:query], params[:size]).all

    @results = []

    if response.success?
      @results = response.results.
                          group_by { |e| e.type }.
                          sort_by { |t, _| TYPE_ORDER.index(t) || 10 }

      respond_to do |format|
        format.html
        format.json { render json: @results }
      end
    else
      flash.alert = t('app.errors.search')
    end
  end

  def autocomplete
    response = Hdo::Search::Searcher.new(params[:query]).autocomplete
    @results = []

    representative_icon = view_context.asset_path("representative.png")
    issue_icon          = view_context.asset_path("issue.png")

    if response.success?
      @results = response.results.map do |r|
        case r.type
        when 'representative'
          img = representative_icon
          url = representative_url(id: r.slug || r.id)
        when 'issue'
          img = issue_icon
          url = issue_url(id: "#{r.id}-#{r.slug}")
        end

        r.as_json.merge(url: url, img_src: img)
      end.group_by { |e| e["_type"] }

      respond_to do |format|
        format.json { render json: @results }
      end
    end
  end

  def promises
    response = Hdo::Search::Searcher.new(params[:query], params[:size]).promises

    respond_to do |format|
      format.json do
        if response.success?
          render json: response.results
        else
          render json: {error: t('app.errors.search')}, status: 500
        end
      end
    end
  end

end
