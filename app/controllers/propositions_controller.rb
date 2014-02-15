class PropositionsController < ApplicationController
  before_filter :fetch_proposition, only: [:show]
  hdo_caches_page :show

  def index
    @search = Hdo::Search::Propositions.new(params, view_context)
  end

  def show
    @proposition = @proposition.decorate
  end

  private

  def fetch_proposition
    @proposition = Proposition.includes(:votes, :proposition_endorsements => :proposer).find(params[:id])
  end
end
