class TopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_topic, :only => [:show, :edit, :update, :destroy]
  before_filter :set_disable_buttons

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
    session[:topic_step] = params[:step] || session[:topic_step] || steps.first
    @topic_steps = steps

    case session[:topic_step]
    when 'categories'
      fetch_categories
    when 'promises'
      # better way to do this?
      @promises = @topic.categories.includes(:promises).map(&:promises).compact.flatten
    when 'votes'
      votes = Vote.includes(:issues, :propositions, :vote_connections).select { |e| e.issues.all?(&:processed?) }
      @votes_and_connections = votes.map { |vote| [vote, @topic.connection_for(vote)] }.sort_by { |vote, connection| connection ? 0 : 1 }
    when 'fields'
      @fields = Field.all
    else
      raise "unknown step: #{session[:topic_step].inspect}"
    end
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      if params[:finish_button]
        redirect_to @topic
      else
        session[:topic_step] = next_step

        redirect_to edit_topic_step_url(@topic, :step => session[:topic_step])
      end
    else
      flash.alert = @topic.errors.full_messages.join(' ')
      redirect_to new_topic_path(@topic)
    end
  end

  def update
    current_step = session[:topic_step]

    if params[:prev_button]
      current_step = previous_step(current_step)
    else
      current_step = next_step(current_step)
    end

    session[:topic_step] = current_step
    set_vote_connections params

    # TODO: check result of save
    @topic.update_attributes(params[:topic])

    if params[:finish_button]
      session.delete :topic_step
      redirect_to @topic
    else
      redirect_to edit_topic_step_url(@topic, step: current_step)
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

  def next_step(step = steps.first)
    steps[steps.index(step) + 1]
  end

  def previous_step(step)
    steps[steps.index(step) - 1]
  end

  def first_step?(step)
    step == steps.first
  end

  def last_step?(step)
    step == steps.last
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


end
