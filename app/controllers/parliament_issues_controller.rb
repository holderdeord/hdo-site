class ParliamentIssuesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @search = Hdo::Search::ParliamentIssues.new(params, view_context)
  end

  def show
    @parliament_issue = ParliamentIssue.includes(:committee, :categories, :votes).find(params[:id])
  end

end
