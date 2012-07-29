class TopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_topic, :only => [:show, :edit, :update, :destroy]
  before_filter :set_disable_buttons
  before_filter :set_steps_list_for_navigation, :only => :edit

  def index
    @topics = Topic.all

    respond_to do |format|
      format.html
      format.json { render json: @topics }
    end
  end

  def show
    @promises_by_party = @topic.promises.group_by { |e| e.party }

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def new
    @topic = Topic.new
    session[:topic_step] = steps.first
    fetch_categories

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def edit
    redirect_to edit_topic_step_url(@topic, step: steps.first) and return unless params[:step]
    session[:topic_step] = params[:step]
    self.send("edit_#{session[:topic_step]}")
  end

  def edit_categories
    fetch_categories
  end

  def edit_promises
    @promises = @topic.categories.includes(:promises).map(&:promises).compact.flatten
  end

  def edit_votes
    votes = Vote.includes(:issues, :propositions, :vote_connections).select { |e| e.issues.all?(&:processed?) }
      @votes_and_connections = votes.map { |vote| [vote, @topic.connection_for(vote)] }.sort_by { |vote, connection| connection ? 0 : 1 }
  end

  def edit_fields
    @fields = Field.all
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      if params[:finish_button]
        redirect_to @topic
      else
        redirect_to edit_topic_step_url(@topic, :step => step_after)
      end
    else
      flash.alert = @topic.errors.full_messages.join(' ')
      redirect_to new_topic_path(@topic)
    end
  end

  def update
    current_step = session[:topic_step]

    set_vote_connections params

    if @topic.update_attributes(params[:topic])
      session[:topic_step] = current_step = next_step params, current_step

      if params[:finish_button]
        session.delete :topic_step
        redirect_to @topic
      else
        redirect_to edit_topic_step_url(@topic, step: current_step)
      end
    else
      flash.alert = @topic.errors.full_messages.join(' ')
      redirect_to edit_topic_step_url(@topic, :step => current_step)
    end
  end

  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  def show_votes
    topic = Topic.find(params[:id])
    render 'votes', locals: { :topic => topic }
  end

  def steps
    %w[categories promises votes fields]
  end

  def step_after(step = steps.first)
    steps[steps.index(step) + 1]
  end

  def step_before(step)
    steps[steps.index(step) - 1]
  end

  def first_step?(step)
    step == steps.first
  end

  def last_step?(step)
    step == steps.last
  end

  def next_step(params, current_step)
    if params[:prev_button]
      current_step = step_before(current_step)
    else
      current_step = step_after(current_step)
    end
  end

  private

  def fetch_categories
    @categories = Category.column_groups
  end

  def fetch_topic
    @topic = Topic.find(params[:id])
  end

  def set_disable_buttons
    @disable_next = last_step?(params[:step]) or @topic && @topic.new_record?
    @disable_prev = first_step?(params[:step])
  end

  def set_vote_connections(params)
    return unless params[:votes]

    @topic.vote_connections = []

    params[:votes].each do |vote_id, data|
      next unless %w[for against].include? data[:direction]

      @topic.vote_connections.create! vote_id: vote_id,
                                      matches: data[:direction] == 'for',
                                      comment: data[:comment],
                                      weight:  data[:weight]
    end
  end

  def set_steps_list_for_navigation
    @topic_steps = steps
  end

end
