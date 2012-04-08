class IssuesController < ApplicationController
  def index
    @issues = Issue.all(:order => :last_update).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @issues }
    end
  end

  def show
    @issue = Issue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @issue }
    end
  end

end
