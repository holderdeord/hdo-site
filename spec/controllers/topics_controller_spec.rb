require 'spec_helper'

describe TopicsController do
  before :each do
    @user = User.make!
    sign_in @user
  end

  it "should get index" do
    topics = [Topic.make!]

    get :index

    response.should be_success
    assigns(:topics).should == topics
  end

  it "should create a new topic with a name" do
    post :create, :topic => { :title => 'More Cowbell' }, :finish => true

    Topic.count.should == 1

    topic = assigns(:topic)
    topic.should be_kind_of(Topic)

    response.should redirect_to(topic_path(topic))
  end

  it 'should render new if save was unsuccessful' do
    post :create, :topic => {}, :finish => true

    flash.alert.should_not be_nil
    response.should render_template(:new)
  end

  it "should show the promises step when hit next from create" do
    post :create, :topic => { :title => "Less Cowbell!" }

    topic = assigns(:topic)
    topic.should be_kind_of(Topic)

    expected_url = edit_topic_step_path(:id => topic, :step => 'promises' )
    response.should redirect_to(expected_url)
  end

  it "should show votes step when hit next from promises" do
    topic = Topic.make!
    session[:topic_step] = 'promises'

    put :update, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to(edit_topic_step_url(topic, :step => 'votes' ))
  end

  it "should show fields step when hit next from votes" do
    topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to(edit_topic_step_url(:step => 'fields' ))
  end

  it "should show votes step when hit previous from fields" do
    topic = Topic.make!
    session[:topic_step] = 'fields'

    put :update, :previous => true, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to edit_topic_step_url(topic, :step => 'votes' )
  end

  it "should show promises when hit previous from votes" do
    topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :previous => true, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to edit_topic_step_url(topic, :step => 'promises')
  end

  it "should show the categories step when hit prev from promises" do
    topic = Topic.make!
    session[:topic_step] = 'promises'

    put :update, :previous => true, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to edit_topic_step_url(topic, :step => 'categories')
  end

  it "should save and redirect to topic when hit finish from edit step" do
    topic = Topic.make!
    session[:topic_step] = 'votes'

    put :update, :finish => true, :topic => topic_params(topic), :id => topic

    assigns(:topic).should == topic
    response.should redirect_to topic_path(topic)
  end

  def topic_params(topic)
    wanted_keys = ['id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids']
    topic.as_json.keep_if { |key| key.in? wanted_keys }
  end

end
