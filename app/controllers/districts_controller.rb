class DistrictsController < ApplicationController
  def index
    @districts = District.includes(:representatives).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @districts }
    end
  end

  def show
    @district = District.includes(:representatives => :party).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @district }
    end
  end

end
