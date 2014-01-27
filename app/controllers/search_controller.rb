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
                          group_by { |e| e._type }.
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
        case r._type
        when 'representative'
          {
            type: r._type,
            img_src: representative_icon,
            url: representative_url(id: r.slug || r._id),
            full_name: r.full_name,
            party_name: r.latest_party.name
          }
        when 'issue'
          {
            type: r._type,
            img_src: issue_icon,
            url: issue_url(id: "#{r._id}-#{r.slug}"),
            title: r.title
          }
        end
      end.group_by { |e| e[:type] }

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
          render json: response.results.map { |pr| pr._source.as_json.merge(id: pr._id)}
        else
          render json: {error: t('app.errors.search')}, status: 500
        end
      end
    end
  end
end
