class PartiesController < ApplicationController
  def index
    @parties = Party.includes(:representatives).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parties }
    end
  end

  def show
    @party = Party.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @party }
    end
  end
end
