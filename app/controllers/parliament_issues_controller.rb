class ParliamentIssuesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @search = Hdo::Search::ParliamentIssues.new(params, view_context)

    respond_to do |format|
      format.html
      format.json { render json: @search.as_json }
      format.csv  { send_data @search.as_csv }
      format.tsv  { send_data @search.as_csv(col_sep: "\t") }
    end
  end

  def show
    @parliament_issue = ParliamentIssue.includes(:committee, :categories, :votes).find(params[:id])
  end

end
