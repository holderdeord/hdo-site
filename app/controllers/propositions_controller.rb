class PropositionsController < ApplicationController
  before_filter :fetch_proposition, only: [:show]

  def index
    searcher = Hdo::Search::Searcher.new(params[:q] || '*')
    @response = searcher.propositions(status: 'published')

    if @response.success?
      @search_response = @response.response
      @propositions = @response.response.page(params[:page] || 1).per(params[:per_page || 50]).records
    else
      flash.error = @response.error_message
      @propositions = []
    end

    @logged_in = current_user && (current_user.admin? || current_user.superadmin?)
  end

  def show
  end

  private

  def fetch_proposition
    @proposition = Proposition.find(params[:id])
  end
end
