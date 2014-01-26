class ParliamentIssuesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @parliament_issues = ParliamentIssue.order(:last_update).reverse_order.page(params[:page])
  end

  def show
    @parliament_issue = ParliamentIssue.includes(:committee, :categories, :votes).find(params[:id])
  end

end
