class DistrictsController < ApplicationController
  caches_page :index, :show

  def index
    @districts = District.includes(:representatives).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @districts }
      format.xml  { render xml:  @districts }
    end
  end

  def show
    @district = District.includes(representatives: {party_memberships: :party}).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @district }
      format.xml  { render xml:  @district }
    end
  end

end
