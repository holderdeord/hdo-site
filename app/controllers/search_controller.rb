class SearchController < ApplicationController
  TYPE_ORDER = %w[
    issue
    topic
    representative
    parliament_issue
    proposition
    promise
  ]

  def all
    response = nil

    ActiveSupport::Notifications.instrument("search.all", :query => params[:query]) {
      response = Hdo::Search::Searcher.new(params[:query]).all
    }

    @results = []

    if response.success?
      @results = response.results.
                          group_by { |e| e.type }.
                          sort_by { |t, _| TYPE_ORDER.index(t) || 10 }
    else
      flash.alert = t('app.errors.search')
    end
  end

  def autocomplete
    response = Hdo::Search::Searcher.new(params[:query]).autocomplete
    @results = []

    if response.success?
      @results = response.results.group_by { |e| e.type }

      respond_to do |format|
        format.html {render layout: false}
      end
    end
  end

end
