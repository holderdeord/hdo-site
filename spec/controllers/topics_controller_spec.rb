require 'spec_helper'

describe TopicsController do
  include Devise::TestHelpers

  before (:each) do
    @user = User.make!
    sign_in @user
  end

  it "should get index" do
    get :index
    response.should be_success
    assert_not_nil assigns(:topics)
  end

  it "should create a new topic with a name" do
    topic_count_before_create = Topic.count
    post :create, :topic => { :title => 'More Cowbell' },
      :finish_button => true
    assert Topic.count == topic_count_before_create + 1
    response.should redirect_to topic_path assigns(:topic) 
  end

  it "should show the promises step when hit next from create" do
    post :create, :topic => { :title => "Less Cowbell!" }
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'promises' )
  end

  it "should show votes step when hit next from promises" do
    post :create, :topic => { :title => "Just as much cowbell!" }
    @topic = assigns(:topic)
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'votes' )
  end

  it "should show fields step when hit next from votes" do
    post :create, :topic => { :title => "Just as much cowbell!" }
    @topic = assigns(:topic)
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'fields' )
  end

  it "should show votes step when hit previous from fields" do
    post :create, :topic => { :title => "Just as much cowbell!" }
    @topic = assigns(:topic)
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    put :update, :prev_button => true, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'votes' )
  end

  it "should show promises when hit previous from votes" do
    post :create, :topic => { :title => "Just as much cowbell!" }
    @topic = assigns(:topic)
    put :update, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    put :update, :prev_button => true, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'promises' )
  end

  it "should show the categories step when hit prev from promises" do
    post :create, :topic => { :title => "Less Cowbell!" }
    @topic = assigns(:topic)
    put :update, :prev_button => true, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to edit_topic_step_url( :id => assigns(:topic).slug, :step => 'categories' )
  end

  it "should save and redirect to topic when hit finish from edit step" do
    post :create, :topic => { :title => "Just as much cowbell!" }
    @topic = assigns(:topic)
    put :update, :finish_button => true, :topic => @topic.as_json.keep_if { |key| key.in? 'id', 'description', 'title', 'category_ids', 'promise_ids', 'field_ids' }, :id => @topic.slug
    response.should redirect_to topic_path @topic
  end

end