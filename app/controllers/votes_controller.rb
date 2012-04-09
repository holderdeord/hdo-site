class VotesController < ApplicationController
  caches_page :index, :show

  def index
    @votes = Vote.includes(:issue).order(:time).reverse_order

    respond_to do |format|
      format.html
      format.json { render json: @votes }
      format.xml  { render xml:  @votes }
    end
  end

  def show
    @vote = Vote.find(params[:id])
    @issue = @vote.issue

    respond_to do |format|
      format.html
      format.json { render json: @vote }
      format.xml  { render xml:  @vote }
    end
  end
end
