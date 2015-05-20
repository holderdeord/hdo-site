class PropositionsController < ApplicationController
  before_filter :fetch_proposition, only: [:show]
  hdo_caches_page :show

  def index
    @search = Hdo::Search::Propositions.new(params, view_context)

    unless current_user && request.xhr?
      @search.ignore :starred
    end

    respond_to do |format|
      format.html
      format.json { render json: @search.as_json }
      format.csv  { send_data @search.as_csv }
      format.tsv  { send_data @search.as_csv(col_sep: "\t") }
    end
  end

  def show
    @parliament_issues = @proposition.parliament_issues
    @proposition = @proposition.decorate
  end

  private

  def fetch_proposition
    @proposition = Proposition.includes(:votes => :parliament_issues, :proposition_endorsements => :proposer).find(params[:id])
  end
end
