require 'spec_helper'

describe TopicsController do

  context 'as a normal user' do
    it 'can show a topic with published issues' do
      topic = Topic.make!
      published = Issue.make!(topics: [topic], status: 'published')
      non_published = Issue.make!(topics: [topic])

      get :show, id: topic

      assigns(:topic).should == topic
      assigns(:issues).should == [published]

      response.should have_rendered(:show)
    end
  end

  context 'as a logged in user' do
    before :each do
      @user = User.make!
      sign_in @user
    end

    it 'can show index' do
      topic = Topic.make!

      get :index

      assigns(:topics).should == [topic]
    end

    it 'can show a topic' do
      topic = Topic.make!

      get :show, id: topic

      assigns(:topic).should == topic
      response.should have_rendered(:show)
    end

    it 'shows other, published issues' do
      topic_a = Topic.make!
      topic_b = Topic.make!

      published = Issue.make!(topics: [topic_b], status: 'published')
      non_published = Issue.make!(topics: [topic_b])

      get :show, id: topic_a

      assigns(:other_issues).should == [published]
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

      response.should redirect_to topics_path
    end
  end

end
