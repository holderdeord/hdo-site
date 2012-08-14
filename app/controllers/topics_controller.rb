class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :votes]
  before_filter :fetch_topic, :only => [:show, :edit, :update, :destroy, :votes, :votes_search]

  helper_method :edit_steps

  def index
    @topics = Topic.order(:title)

    respond_to do |format|
      format.html
      format.json { render json: @topics }
    end
  end

  def show
    # introduce a policy object?
    if @topic.published? || user_signed_in?
      @promises_by_party = @topic.promises.group_by { |e| e.party }

      assign_party_groups
      assign_previous_and_next_topics

      respond_to do |format|
        format.html
        format.json { render json: @topic }
      end
    else
      redirect_to root_url
    end
  end

  def new
    @topic = Topic.new
    fetch_categories

    edit_steps.first!

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def edit
    if edit_steps.from_param
      assign_disable_buttons
      assign_topic_steps

      step = edit_steps.from_param!
      send "edit_#{step}"
    else
      redirect_to edit_topic_step_url(@topic, :step => edit_steps.first)
    end
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.save
      if edit_steps.finish?
        redirect_to @topic
      else
        redirect_to edit_topic_step_url(@topic, :step => edit_steps.after)
      end
    else
      flash.alert = @topic.errors.full_messages.to_sentence
      fetch_categories

      render :action => :new
    end
  end

  def update
    update_vote_connections

    if @topic.update_attributes(params[:topic])
      edit_steps.next!

      if edit_steps.finish?
        session.delete :topic_step
        redirect_to @topic
      else
        redirect_to edit_topic_step_url(@topic, step: edit_steps.current)
      end
    else
      flash.alert = @topic.errors.full_messages.to_sentence
      redirect_to edit_topic_step_url(@topic, :step => edit_steps.current)
    end
  end

  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  def votes
    if @topic.published? || user_signed_in?
      assign_party_groups
      render locals: { topic: @topic, party_groups: @party_groups }
    else
      redirect_to root_path
    end
  end

  def votes_search
    votes = Vote.naive_search(
      params[:filter],
      params[:keyword],
      @topic.categories
    )

    # remove already connected votes
    votes -= @topic.vote_connections.map { |e| e.vote }
    votes.map! { |vote| [vote, nil] }

    render partial: 'votes_list', locals: { votes_and_connections: votes }
  end

  private

  def assign_previous_and_next_topics(order = :title)
    topics = Topic.order(order)
    topics = topics.published unless user_signed_in?

    @previous_topic = topics[topics.index(@topic) - 1] if topics.index(@topic) > 0
    @next_topic     = topics[topics.index(@topic) + 1] if topics.index(@topic) < topics.size
  end

  def assign_party_groups
    @party_groups = Party.governing_groups
  end

  def edit_categories
    fetch_categories
  end

  def edit_promises
    @promises = @topic.categories.includes(:promises).map(&:promises).compact.flatten.uniq.sort_by { |e| e.party.name }
  end

  def edit_votes
    @votes_and_connections = @topic.vote_connections.map { |e| [e.vote, e] }
  end

  def edit_fields
    @fields = Field.all
  end

  def fetch_categories
    @categories = Category.column_groups
  end

  def fetch_topic
    @topic = Topic.find(params[:id])
  end

  def update_vote_connections
    return unless params[:votes]

    #
    # Clear and re-create all connections. This has two benefits:
    #
    # * Connections removed by unchecking a checkbox will also be removed.
    # * Ensures that the TopicsController#stats cache is cleared.
    #
    # TODO: make sure the connections are properly deleted from the DB, or
    # the association table will grow on every edit.
    #
    @topic.vote_connections = []

    params[:votes].each do |vote_id, data|
      next unless %w[for against].include? data[:direction]

      @topic.vote_connections.create! vote_id:      vote_id,
                                      matches:      data[:direction] == 'for',
                                      comment:      data[:comment],
                                      weight:       data[:weight],
                                      description:  data[:description]
    end
  end

  def assign_topic_steps
    @topic_steps = Hdo::TopicEditSteps::STEPS
  end

  def assign_disable_buttons
    @disable_next = edit_steps.last?(params[:step]) or @topic && @topic.new_record?
    @disable_prev = edit_steps.first?(params[:step])
  end

  def edit_steps
    @edit_steps ||= Hdo::TopicEditSteps.new(params, session)
  end

end
