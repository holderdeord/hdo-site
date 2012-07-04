class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :fetch_topic, :only => [:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all

    respond_to do |format|
      format.html
      format.json { render json: @topics }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def new
    @topic = Topic.new
    fetch_categories

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def edit
    @topic.current_step = params[:step] || session[:topic_step]

    case @topic.current_step
    when 'categories'
      fetch_categories
    when 'promises'
      # better way to do this?
      @promises = @topic.categories.includes(:promises).map(&:promises).compact.flatten
    when 'votes'
      @votes = Vote.includes(:propositions).limit(50).order("time DESC")
    else
      raise "unknown step: #{@topic.current_step.inspect}"
    end
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.save
      @topic.next_step!
      session[:topic_step] = @topic.current_step

      redirect_to edit_topic_url(@topic)
    else
      flash.alert = @topic.errors.full_messages.join(' ')
      redirect_to new_topic_path(@topic)
    end
  end

  def update
    @topic.current_step = session[:topic_step]

    if params[:prev_button]
      @topic.previous_step
    else
      @topic.next_step!
    end

    session[:topic_step] = @topic.current_step
    set_vote_directions params

    @topic.update_attributes(params[:topic])

    if params[:finish_button]
      session.delete :topic_step
      redirect_to @topic
    else
      redirect_to edit_topic_url(@topic)
    end
  end

  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  private

  def fetch_categories
    @categories = Category.column_groups
  end

  def fetch_topic
    @topic = Topic.find(params[:id])
  end

  def set_vote_directions(params)
    return unless params[:votes_for]

    @topic.vote_directions = []

    params[:votes_for].each do |vote_id, value|
      next unless ['for', 'against'].include? value

      @topic.vote_directions.create! vote_id: vote_id,
                                     matches: value == 'for'
    end
  end

end
