class TopicsController < ApplicationController
  def index
    @topics = Topic.includes(:children).all(:order => :name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  def show
    @topic = Topic.includes(:issues).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topic }
    end
  end

end
