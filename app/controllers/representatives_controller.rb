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
    @issues         = Issue.published.order(:title).all.reject { |i| i.stats.score_for(@representative).nil? }

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end

end
