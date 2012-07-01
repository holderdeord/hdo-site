class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :fetch_categories, :only => [:edit, :new]
  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
    if(params[:skip_to_step])
      @topic.current_step = params[:skip_to_step]
    else
      @topic.current_step = session[:topic_step]
    end

    if(@topic.current_step == "categories")
      fetch_categories
    elsif(@topic.current_step == "promises")
      @promises = Promise.find_all_by_id(@topic.categories.collect{ |cat| cat.promise_ids })
    elsif(@topic.current_step == "votes")
      @votes = Vote.all
    end
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(params[:topic])
    @topic.next_step
    session[:topic_step] = @topic.current_step
    @topic.save!

    redirect_to proc { edit_topic_url(@topic) }
  end

  def process_vote_directions(topic, params)
    votes_for = params[:votes_for]
    if(votes_for)
      topic.vote_directions = []
      votes_for.each_pair do |vote_id, matches|
        vote = Vote.find(vote_id)
        topic.vote_directions << VoteDirection.new(:topic => topic,
          :vote => vote,
          :matches => matches)
      end
    end
  end

  def set_vote_directions(vote_ids, topic, matches)
    votes = Vote.find_all_by_id vote_ids
      votes.each do |vote|
        topic.vote_directions << VoteDirection.new(:topic => topic,
            :vote => vote,
            :matches => matches)
      end
  end

  # PUT /topics/1
  # PUT /topics/1.json
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
    @topic.update_attributes(params[:topic])
    if(params[:finish_button])
      session[:topic_step] = nil
      redirect_to @topic
      return
    else
      redirect_to proc { edit_topic_url(@topic) }
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
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
    @categories = Category.all
  end
end
