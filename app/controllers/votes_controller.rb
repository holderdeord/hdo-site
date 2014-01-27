class VotesController < ApplicationController
  hdo_caches_page :index, :show, :all

  DEFAULT_PER_PAGE = 30

  def index
    @votes = Vote.with_results.includes(:parliament_issues).order(:time).reverse_order

    per_page = params[:per_page].to_i > 0 ? params[:per_page] : DEFAULT_PER_PAGE
    @votes = @votes.page(params[:page]).per(per_page)
  end

  def show
    @vote = Vote.with_results.find(params[:id])

    if stale?(@vote, public: can_cache?)
      @parliament_issues = @vote.parliament_issues
      @stats             = @vote.stats
      @vote_results      = @vote.vote_results.includes(representative: {party_memberships: :party})
      @issues            = @vote.propositions.flat_map { |e| e.proposition_connections.map(&:issue) }.select(&:published?).uniq

      @results_by_party  = Party.order(:name).each_with_object({}) { |party, obj| obj[party] = {:for => [], :against => [], :absent => []} }
      @vote.vote_results.each do |result|
        @results_by_party[result.representative.party_at(@vote.time)][result.state] << result
      end

      @results_by_party.delete_if { |party, data| data.values.all?(&:empty?) }
    end
  end

  def propositions
    vote = Vote.find(params[:id])
    @propositions = vote ? vote.propositions.order(:id) : []
    @layout = !request.xhr?

    render layout: @layout
  end

end
