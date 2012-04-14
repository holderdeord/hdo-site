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
    @representative = Representative.includes(:votes => :issue).find(params[:id])

    # TODO: do this in DB?
    @vote_results = @representative.vote_results.sort_by { |e| e.vote.time }.reverse

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end
end
