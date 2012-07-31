require 'spec_helper'

describe TopicsController do
  before :each do
    @user = User.make!
    sign_in @user
  end

  it "should get index" do
    get :index

    response.should be_success
    assigns(:topics).should_not be_nil
  end

  it "should create a new topic with a name" do
    topic_count_before_create = Topic.count

    post :create, :topic => { :title => 'More Cowbell' },
      :finish_button => true

    Topic.count.should eq topic_count_before_create + 1
    topic = assigns(:topic)
    topic.should be_kind_of(Topic)

    response.should redirect_to topic_path topic
  end

  it "should show the promises step when hit next from create" do
    post :create, :topic => { :title => "Less Cowbell!" }

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'promises' )
    assigns(:topic).should_not be_nil
  end

  it "should show votes step when hit next from promises" do
    @topic = Topic.make!
    session[:topic_step] = 'promises'

    put :update, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'votes' )
  end

  it "should show fields step when hit next from votes" do
    @topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'fields' )
  end

  it "should show votes step when hit previous from fields" do
    @topic = Topic.make!
    session[:topic_step] = 'fields'

    put :update, :prev_button => true, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'votes' )
  end

  it "should show promises when hit previous from votes" do
    @topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :prev_button => true, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'promises' )
  end

  it "should show the categories step when hit prev from promises" do
    @topic = Topic.make!
    session[:topic_step] = 'promises'

    put :update, :prev_button => true, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'categories' )
  end

  it "should save and redirect to topic when hit finish from edit step" do
    @topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :finish_button => true, :topic => topic_params(@topic), :id => @topic.slug

    response.should redirect_to topic_path @topic
  end

  def topic_params(topic)
    topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }
  end

end
