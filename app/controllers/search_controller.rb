class SearchController < ApplicationController
  def all
    response = Hdo::Search::Searcher.new(params[:query]).all

    if response.success?
      @results = response.results

      respond_to do |format|
        format.json { render json: @results }
        format.html
      end
    else
      flash.alert = t('app.error')
      redirect_to root_path
    end
  end
end
