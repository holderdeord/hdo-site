require 'spec_helper'

describe TopicsController do
  let(:topic) { Topic.make! }
  
  before :each do
    @user = User.make!
    sign_in @user
  end
  
  def topic_params(topic)
    wanted_keys = ['id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids']
    topic.as_json.keep_if { |key| key.in? wanted_keys }
  end

  it "should get :index" do
    topics = [topic]

    get :index

    assigns(:topics).should == topics
    response.should have_rendered(:index)
  end
  
  it 'should get :show' do
    get :show, id: topic
      
    assigns(:topic).should == topic
    assigns(:promises_by_party).should_not be_nil
    response.should have_rendered(:show)
  end
  
  it 'should get :new' do
    get :new
    
    response.should have_rendered(:new)
    
    session[:topic_step].should == 'categories'
    assigns(:categories).should_not be_nil
  end
  
  it 'edit redirects to the categories step if no step was specified' do
    get :edit, id: topic
    
    response.should redirect_to(edit_topic_step_path(topic, step: 'categories'))
  end
  
  it 'edits the vote step if specified' do
    get :edit, id: topic, step: 'votes'
    
    response.should have_rendered(:edit)
    assigns(:votes_and_connections).should_not be_nil
  end

  it 'edits the promises step if specified' do
    get :edit, id: topic, step: 'promises'
    
    response.should have_rendered(:edit)
    assigns(:promises).should_not be_nil
  end

  it 'edits the cateogires step if specified' do
    get :edit, id: topic, step: 'categories'
    
    response.should have_rendered(:edit)
    assigns(:categories).should_not be_nil
  end

  it 'edits the fields step if specified' do
    get :edit, id: topic, step: 'fields'
    
    response.should have_rendered(:edit)
    assigns(:fields).should_not be_nil
  end
  
  it "should create a new topic with a name" do
    post :create, topic: { title: 'More Cowbell' }, finish: true

    Topic.count.should == 1

    topic = assigns(:topic)
    topic.should be_kind_of(Topic)

    response.should redirect_to(topic_path(topic))
  end

  it 'should render new if save was unsuccessful' do
    post :create, topic: {}, finish: true

    flash.alert.should_not be_nil
    response.should render_template(:new)
  end
  
  context "failed update" do
    it 'should re-edit categories if update was unsuccessful' do
      pending "can this actually happen?"
    end

    it 'should re-edit promises if update was unsuccessful' do
      pending "can this actually happen?"
    end
    
    it 'should re-edit votes if update was unsuccessful' do
      pending "can this actually happen?"
    end

    it 'should re-edit fields if update was unsuccessful' do
      pending "can this actually happen?"
    end
  end
  
  context 'destroy' do
    it 'should destroy the topic' do
      delete :destroy, id: topic
      
      Topic.count.should == 0
      response.should redirect_to(topics_url)
    end
  end
  
  context "next" do
    it "should show the promises step when hit next from create" do
      post :create, topic: { title: "Less Cowbell!" }

      topic = assigns(:topic)
      topic.should be_kind_of(Topic)

      expected_url = edit_topic_step_path(id: topic, step: 'promises')
      response.should redirect_to(expected_url)
    end

    it "should show votes step when hit next from promises" do
      session[:topic_step] = 'promises'

      put :update, topic: topic_params(topic), id: topic

      assigns(:topic).should == topic
      session[:topic_step].should == 'votes'
    
      response.should redirect_to(edit_topic_step_url(topic, step: 'votes'))
    end

    it "should show fields step when hit next from votes" do
      session[:topic_step] = 'votes'

      put :update, topic: topic_params(topic), id: topic
    
      session[:topic_step].should == 'fields'
      assigns(:topic).should == topic
      response.should redirect_to(edit_topic_step_url(step: 'fields' ))
    end
  end
  
  context "previous" do
    it "should show votes step when hit previous from fields" do
      session[:topic_step] = 'fields'

      put :update, previous: true, topic: topic_params(topic), id: topic

      session[:topic_step].should == 'votes'
      assigns(:topic).should == topic
      response.should redirect_to edit_topic_step_url(topic, step: 'votes' )
    end
    
    it "should show promises when hit previous from votes" do
      session[:topic_step] = 'votes'

      put :update, previous: true, topic: topic_params(topic), id: topic

      session[:topic_step].should == 'promises'
      assigns(:topic).should == topic
      response.should redirect_to edit_topic_step_url(topic, step: 'promises')
    end
    
    it "should show the categories step when hit previous from promises" do
      session[:topic_step] = 'promises'

      put :update, previous: true, topic: topic_params(topic), id: topic

      session[:topic_step] = 'categories'
      assigns(:topic).should == topic
      response.should redirect_to edit_topic_step_url(topic, step: 'categories')
    end
  end
  
  context "finish" do
    it "should save and redirect to topic when hit finish from edit step" do
      session[:topic_step] = 'votes'

      put :update, finish: true, topic: topic_params(topic), id: topic

      assigns(:topic).should == topic
      response.should redirect_to topic_path(topic)
    end
  end

end
