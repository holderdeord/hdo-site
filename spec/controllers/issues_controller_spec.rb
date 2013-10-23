require 'spec_helper'

describe IssuesController do
  let(:issue) { Issue.make! }

  it 'should get :show if the issue is published' do
    issue.update_attributes! status: 'published'

    get :show, id: issue

    response.should have_rendered(:show)
    assigns(:issue).should be_decorated_with(IssueDecorator)
  end

  it 'should get :votes if the issue is published' do
    issue.update_attributes! status: 'published'

    get :votes, id: issue

    response.should have_rendered(:votes)
    assigns(:issue_votes).should be_kind_of(Enumerable)
  end

  it 'should redirect :show to the front page if the issue is not published' do
    get :show, id: issue
    response.should redirect_to(new_user_session_path)
  end

  it 'should redirect :votes to the front page if the issue is not published' do
    get :votes, id: issue
    response.should redirect_to(new_user_session_path)
  end

  it 'permanently redirects slug URLs to correct URL' do
    get :show, id: issue.slug
    response.should redirect_to(issue_url(issue))
    response.status.should == 301

    get :votes, id: issue.slug
    response.should redirect_to(votes_issue_url(issue))
    response.status.should == 301
  end

  context "with rendered views" do
    render_views

    it "should render :show" do
      Government.make!(start_date: Date.new(2009, 10, 1), end_date: Date.new(2013, 10, 1))

      get :show, id: Issue.make!(status: 'published', published_at: Time.now)
      response.should have_rendered(:show)
    end
  end

  it 'does not render admin_info' do
    get :admin_info, id: issue

    response.should be_success
    response.body.should be_blank
  end

  context 'as a logged in user' do
    let(:user)    { User.make! }
    before(:each) { sign_in user }

    it 'should get :show for a logged in user' do
      get :show, id: issue

      assigns(:issue).should be_decorated_with(IssueDecorator)
      response.should have_rendered(:show)
    end

    it 'renders admin_info' do
      get :admin_info, id: issue

      response.should be_success
      response.should have_rendered(:admin_info)
    end
  end

end
