class RepresentativesController < ApplicationController
  # GET /representatives
  # GET /representatives.json
  def index
    @representatives = Representative.order :last_name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @representatives }
    end
  end

  # GET /representatives/1
  # GET /representatives/1.json
  def show
    @representative = Representative.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @representative }
    end
  end
end
