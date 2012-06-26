class IssuesController < ApplicationController
  caches_page :index, :show

  def index
    @issues = Issue.order(:last_update).reverse_order.all

    respond_to do |format|
      format.html
      format.json { render json: @issues }
      format.xml { render xml: @issues }
    end
  end

  def show
    @issue = Issue.includes(:committee, :categories, :votes).find(params[:id])
    @issue_as_array = [@issue]

    respond_to do |format|
      format.html
      format.json { render json: @issue }
      format.xml  { render xml: @issue }
    end
  end

end
