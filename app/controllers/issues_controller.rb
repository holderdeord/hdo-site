class IssuesController < ApplicationController
  caches_page :index, :show

  def index
    @issues = Issue.order(:last_update).reverse_order.all #(:order => :last_update).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @issues }
    end
  end

  def show
    @issue = Issue.includes(:committee, :topics, :votes).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @issue }
    end
  end

end
