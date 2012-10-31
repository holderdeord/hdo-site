class Admin::TopicsController < AdminController
  before_filter :fetch_issues, :only => [:new, :edit]
  before_filter :fetch_topic,  :only => [:edit, :update, :destroy]

  def index
    @topics = Topic.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  def edit
  end

  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render json: @topic, status: :created, location: @topic }
      else
        format.html { render action: "new" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
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

  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to admin_topics_url }
      format.json { head :no_content }
    end
  end

  private

  def assign_previous_and_next_topic
    @previous_topic, @next_topic = @topic.previous_and_next(order: :name)
  end

  def fetch_issues
    @issues = Issue.order :title
  end

  def fetch_topic
    @topic = Topic.find(params[:id])
  end
end
