class PropositionsController < ApplicationController
  before_filter :fetch_proposition, only: [:show]

  def index
    @search = Hdo::Search::Propositions.new(params)
  end

  def show
    @proposition = @proposition.decorate
  end

  private

  def fetch_proposition
    @proposition = Proposition.includes(:votes, :proposition_endorsements => :proposer).find(params[:id])
  end
end
