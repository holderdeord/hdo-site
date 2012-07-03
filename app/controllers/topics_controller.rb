class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :fetch_categories, :only => [:edit, :new]

  def index
    @topics = Topic.all

    respond_to do |format|
      format.html
      format.json { render json: @topics }
    end
  end

  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def new
    @topic = Topic.new

    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def edit
    @topic = Topic.find(params[:id])

    @topic.current_step = params[:skip_to_step] || session[:topic_step]

    case @topic.current_step
    when 'categories'
      fetch_categories
    when 'promises'
      @promises = Promise.find_all_by_id(@topic.categories.collect{ |cat| cat.promise_ids })
    when 'votes'
      @votes = Vote.includes(:propositions).all
    else
      raise "unknown step: #{@topic.current_step.inspect}"
    end
  end

  def create
    @topic = Topic.new(params[:topic])
    @topic.next_step
    session[:topic_step] = @topic.current_step
    @topic.save!

    redirect_to edit_topic_url(@topic)
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.current_step = session[:topic_step]

    if params[:prev_button]
      @topic.previous_step
    else
      @topic.next_step
    end

    session[:topic_step] = @topic.current_step
    process_vote_directions @topic, params

    # if all categories were removed, :category_ids won't be submitted from the browser.
    params[:topic][:category_ids] ||= []

    @topic.update_attributes(params[:topic])

    if params[:finish_button]
      session.delete :topic_step
      redirect_to @topic
    else
      redirect_to edit_topic_url(@topic)
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  private

  def fetch_categories
    column_count = 3
    category_count = Category.count
    cat_groups = Category.where( :main => true).includes(:children) #.in_groups_of(Category.where(:main => true).count / 3, false)
    column_length = (category_count / column_count)

    lengths = []
    sum = 0
    prev_i = 0
    cat_groups.each_with_index do |cat_group, i|
      sum += (cat_group.children.count + 1)
      if(sum >= column_length)
        sum = 0
        lengths << (i - prev_i)
        prev_i = i
      end
    end

    @categories = []
    lengths.each do |l|
      @categories << cat_groups.shift(l)
    end
    @categories << cat_groups
  end

  def process_vote_directions(topic, params)
    return unless params[:votes_for]

    topic.vote_directions = []
    params[:votes_for].each_pair do |vote_id, matches|
      vote = Vote.find(vote_id)
      topic.vote_directions.create! topic: topic,
                                    vote:  vote,
                                    matches: matches
    end
  end

  def set_vote_directions(vote_ids, topic, matches)
    votes = Vote.find_all_by_id vote_ids
    votes.each do |vote|
      topic.vote_directions.create! topic: topic,
                                    vote: vote,
                                    matches: matches
    end
  end

end
