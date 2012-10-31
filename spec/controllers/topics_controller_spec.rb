require 'spec_helper'

describe TopicsController do

  it 'can show a topic with published issues' do
    topic = Topic.make!
    published = Issue.make!(topics: [topic], status: 'published')
    non_published = Issue.make!(topics: [topic])

    get :show, id: topic

    assigns(:topic).should == topic
    assigns(:issues).should == [published]

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

  context 'as a logged in user' do
    let(:user)    { User.make! }
    before(:each) { sign_in user }

    it 'can show a topic' do
      topic = Topic.make!

      get :show, id: topic

      assigns(:topic).should == topic
      response.should have_rendered(:show)
    end
  end

end
