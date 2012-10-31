require 'spec_helper'

describe Admin::TopicsController do
  let(:user)    { User.make! }
  before(:each) { sign_in user }

  it 'can show index' do
    topic = Topic.make!

    get :index

    assigns(:topics).should == [topic]
  end

  it 'can edit a topic' do
    topic = Topic.make!

    get :edit, id: topic

    assigns(:topic).should == topic
    response.should have_rendered(:edit)
  end

  it 'can update a topic' do
    topic = Topic.make!

    put :update, id: topic, topic: { name: 'hello' }

    assigns(:topic).should == topic.reload
    topic.name.should == 'hello'

    response.should redirect_to topic_path(topic)
  end

  it 'can destroy a topic' do
    topic = Topic.make!

    delete :destroy, id: topic

    response.should redirect_to admin_topics_path
  end
end