class VotesController < ApplicationController
  caches_page :index, :show

  def index
    @votes = Vote.order(:time).reverse_order

    respond_to do |format|
      format.html
      format.json { render json: @votes }
    end
  end

  def show
    @vote = Vote.find(params[:id])
    @issue = @vote.issue

    respond_to do |format|
      format.html
      format.json { render json: @vote }
    end
  end
end
