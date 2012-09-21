class VotesController < ApplicationController
  caches_page :index, :show, :all

  DEFAULT_PER_PAGE = 30

  def index
    render_votes_index :paginate => true
  end

  def show
    @vote = Vote.includes(
      :parliament_issues, :vote_results => {:representative => :party},
    ).find(params[:id])

    @parliament_issues = @vote.parliament_issues
    @stats  = @vote.stats

    respond_to do |format|
      format.html
      format.json { render json: @vote }
      format.xml  { render xml:  @vote }
    end
  end

  def propositions
    vote = Vote.includes(:propositions).find(params[:id])
    @propositions = vote ? vote.propositions : []

    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @propositions }
    end
  end

  private

  def render_votes_index(opts = {})
    @votes = Vote.includes(:parliament_issues).order(:time).reverse_order

    if opts[:paginate]
      per_page = params[:per_page].to_i > 0 ? params[:per_page] : DEFAULT_PER_PAGE
    else
      per_page = @votes.count
    end

    @votes = @votes.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @votes }
      format.xml  { render xml:  @votes }
    end
  end
end
