class PartiesController < ApplicationController
  caches_page :index, :show

  def index
    @parties = Party.includes(:representatives).all

    respond_to do |format|
      format.html
      format.json { render json: @parties }
      format.xml  { render xml:  @parties }
    end
  end

  def show
    @party = Party.includes(:representatives, :promises => :categories).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @party }
      format.xml  { render xml:  @party }
    end
  end
end
