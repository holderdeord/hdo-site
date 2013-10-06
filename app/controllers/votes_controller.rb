class VotesController < ApplicationController
  hdo_caches_page :index, :show, :all

  DEFAULT_PER_PAGE = 30

  def index
    @votes = Vote.with_results.includes(:parliament_issues).order(:time).reverse_order

    per_page = params[:per_page].to_i > 0 ? params[:per_page] : DEFAULT_PER_PAGE
    @votes = @votes.paginate(:page => params[:page], :per_page => per_page)
  end

  def show
    @vote = Vote.with_results.find(params[:id])

    if stale?(@vote, public: can_cache?)
      @parliament_issues = @vote.parliament_issues
      @stats             = @vote.stats
      @vote_results      = @vote.vote_results.includes(representative: {party_memberships: :party})
    end
  end

  def propositions
    vote = Vote.find(params[:id])
    @propositions = vote ? vote.propositions.order(:id) : []
    @layout = !request.xhr?

    render layout: @layout
  end

end
