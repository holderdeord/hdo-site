class RepresentativesController < ApplicationController
  caches_page :index, :show,
              :index_by_district, :index_by_party, :index_by_name

  before_filter :fetch_representatives, :only => [:index, :index_by_district, :index_by_party, :index_by_name]

  def index
    respond_to do |format|
      format.html
      format.json { render json: Representative.order(:last_name) }
    end
  end

  def show
    @representative  = Representative.includes(:votes => :parliament_issues).find(params[:id])

    all_vote_results = @representative.vote_results.sort_by { |result| result.vote.time }.reverse
    @activity_stats  = Hdo::Charts::Activity.new(@representative.full_name, all_vote_results)
    @vote_results    = all_vote_results.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end

  def index_by_district
    xhr_only {
      @by_district = @representatives.group_by { |e| e.district }
      render partial: 'index_by_district', locals: { groups: @by_district }
    }
  end

  def index_by_party
    xhr_only {
      @by_party = @representatives.group_by { |e| e.current_party }
      render partial: 'index_by_party', locals: { groups: @by_party }
    }
  end

  def index_by_name
    xhr_only {
      render partial: 'index_by_name', locals: { representatives: @representatives }
    }
  end

  private

  def fetch_representatives
    @representatives = Representative.includes(:district, :party_memberships => :party).order(:last_name)
  end
end
