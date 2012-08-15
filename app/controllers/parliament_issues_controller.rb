class ParliamentIssuesController < ApplicationController
  caches_page :index, :show

  def index
    @parliament_issues = ParliamentIssue.order(:last_update).reverse_order.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @parliament_issues }
      format.xml { render xml: @parliament_issues }
    end
  end

  def show
    @parliament_issue = ParliamentIssue.includes(:committee, :categories, :votes).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @parliament_issue }
      format.xml  { render xml: @parliament_issue }
    end
  end

end
