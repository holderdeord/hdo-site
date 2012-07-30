class RepresentativesController < ApplicationController
  caches_page :show

  def show
    @representative  = Representative.includes(:votes => :issues).find(params[:id])

    all_vote_results = @representative.vote_results.sort_by { |result| result.vote.time }.reverse
    @activity_stats  = Hdo::Charts::Activity.new(@representative.full_name, all_vote_results)

    @vote_results = all_vote_results.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end
end
