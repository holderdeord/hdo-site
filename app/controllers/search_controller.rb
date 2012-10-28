class SearchController < ApplicationController
  def all
    response = Hdo::Search::Searcher.new(params[:query]).all
    @results = []

    if response.success?
      @results = response.results.group_by { |e| e.type }

      respond_to do |format|
        format.json { render json: @results }
        format.html
      end
    else
      flash.alert = t('app.errors.search')
    end
  end
end
