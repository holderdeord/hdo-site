class TopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_topic, :only => [:show, :edit, :update, :destroy]

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
      votes = Vote.includes(:issues, :propositions, :vote_connections).select { |e| e.issues.all?(&:processed?) }
      @votes_and_connections = votes.map { |vote| [vote, @topic.connection_for(vote)] }.sort_by { |vote, connection| connection ? 0 : 1 }
    when 'fields'
      @fields = Field.all
    else
      raise "unknown step: #{@topic.current_step.inspect}"
    end
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      if params[:finish_button]
        redirect_to @topic
      else
        @topic.next_step!
        session[:topic_step] = @topic.current_step

        redirect_to edit_topic_step_url(@topic, :step => @topic.current_step)
      end
    else
      flash.alert = @topic.errors.full_messages.join(' ')
      redirect_to new_topic_path(@topic)
    end
  end

  def update
    @topic.current_step = session[:topic_step]

    if params[:prev_button]
      @topic.previous_step!
    else
      @topic.next_step!
    end

    session[:topic_step] = @topic.current_step
    set_vote_connections params

    # TODO: check result of save
    @topic.update_attributes(params[:topic])

    if params[:finish_button]
      session.delete :topic_step
      redirect_to @topic
    else
      redirect_to edit_topic_step_url(@topic, step: @topic.current_step)
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

  private

  def fetch_categories
    @categories = Category.column_groups
  end

  def fetch_topic
    @topic = Topic.find(params[:id])
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
