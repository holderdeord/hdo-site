class CommitteesController < ApplicationController
  caches_page :index, :show

  def index
    @committees = Committee.includes(:representatives).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @committees }
      format.xml  { render xml: @committees  }
    end
  end

  def show
    @committee = Committee.includes(:representatives => :party).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @committee }
      format.xml  { render xml: @committee }
    end
  end

end
