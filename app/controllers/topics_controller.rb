class TopicsController < ApplicationController
  caches_page :index, :show

  def index
    @topics = Topic.includes(:children).all(:order => :name)

    respond_to do |format|
      format.html
      format.json { render json: @topics }
      format.xml  { render xml:  @topics }
    end
  end

  def show
    @topic = Topic.includes(:issues).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @topic }
      format.xml  { render xml:  @topic }
    end
  end

end
