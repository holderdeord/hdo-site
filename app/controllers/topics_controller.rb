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
    session[:topic_params].deep_merge!(params[:topic]) if params[:topic]
    @topic = Topic.new(session[:topic_params])
    @topic.current_step = session[:topic_step]

    if(@topic.current_step == "promises")
      @promises = Promise.find_all_by_id(@topic.categories.collect{ |cat| cat.promise_ids })
    elsif(@topic.current_step == "categories")
      fetch_categories    
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
  end

  # POST /topics
  # POST /topics.json
  def create
    session[:topic_params] ||= {}
    session[:topic_params].deep_merge!(params[:topic]) if params[:topic]
    @topic = Topic.new(session[:topic_params])
    @topic.current_step = session[:topic_step]

    if(params[:prev_button])
      @topic.previous_step
    elsif @topic.last_step?
      @topic.save
    else
      @topic.next_step
    end
    session[:topic_step] = @topic.current_step

    if @topic.new_record?
      redirect_to :action => 'new'
    else
      session[:topic_params] = session[:topic_step] = nil
      redirect_to @topic
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
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
