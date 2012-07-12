class VotesController < ApplicationController
  caches_page :index, :show

  DEFAULT_PER_PAGE = 30

  def index
    per_page = params[:per_page].to_i > 0 ? params[:per_page] : DEFAULT_PER_PAGE

    @votes = Vote.includes(:issues).
                  paginate(:page => params[:page], :per_page => per_page).
                  order(:time).reverse_order

    respond_to do |format|
      format.html
      format.json { render json: @votes }
      format.xml  { render xml:  @votes }
    end
  end

  def show
    @vote = Vote.includes(
      :issues, :vote_results => {:representative => :party},
    ).find(params[:id])

    @issues = @vote.issues
    @stats  = @vote.stats

    respond_to do |format|
      format.html
      format.json { render json: @vote }
      format.xml  { render xml:  @vote }
    end
  end
end
