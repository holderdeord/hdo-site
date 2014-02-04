class PropositionsController < ApplicationController
  before_filter :fetch_proposition, only: [:show]

  def index
    searcher = Hdo::Search::Searcher.new(params[:q] || '*')
    response = searcher.propositions(status: 'published')

    if response.success?
      @search_response = response.response
      propositions = response.response.page(params[:page] || 1).per(params[:per_page || 50]).records
    else
      flash.error = response.error_message
      propositions = []
    end

    @propositions_feed = Hdo::Utils::PropositionsFeed.new(propositions, see_all: false)
  end

  def show
    @proposition = @proposition.decorate
  end

  private

  def fetch_proposition
    @proposition = Proposition.includes(:votes, :proposition_endorsements => :proposer).find(params[:id])
  end
end
