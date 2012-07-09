class RepresentativesController < ApplicationController
  caches_page :index, :show

  def index
    @representatives = Representative.includes(:party).order :last_name

    respond_to do |format|
      format.html
      format.json { render json: @representatives }
      format.xml  { render xml:  @representatives }
    end
  end

  def show
    @representative  = Representative.includes(:votes => :issues).find(params[:id])
    
    all_vote_results = @representative.vote_results.sort_by { |result| result.vote.time }.reverse
    @vote_results = all_vote_results.paginate(:page => params[:page])
    
    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end
end
