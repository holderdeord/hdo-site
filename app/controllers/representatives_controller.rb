class RepresentativesController < ApplicationController
  hdo_caches_page :index

  def index
    @representatives = Representative.includes(:district, :party_memberships => :party).order(:last_name)

    respond_to do |format|
      format.html
      format.json { render json: @representatives }
    end
  end

  def show
    @representative = Representative.find(params[:id])
    @party          = @representative.latest_party
    @issue_groups   = Issue.published.order(:title).grouped_by_position(@representative)

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end

end
