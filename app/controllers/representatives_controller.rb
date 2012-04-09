class RepresentativesController < ApplicationController
  caches_page :index, :show

  def index
    @representatives = Representative.includes(:party).order :last_name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @representatives }
    end
  end

  def show
    @representative = Representative.includes(:votes).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @representative }
    end
  end
end
