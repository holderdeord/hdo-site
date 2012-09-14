require 'spec_helper'

describe IssuesController do
  let(:issue) { Issue.make! }

  def issue_params(issue)
    issue.as_json.except('created_at', 'id', 'last_updated_by_id', 'slug', 'updated_at')
  end

  def votes_params(connections)
    params = {}

    connections.each do |connection|
      params[connection.vote_id] = {
        :direction   => connection.matches? ? 'for' : 'against',
        :weight      => connection.weight,
        :comment     => connection.comment,
        :description => connection.description
      }
    end

    params
  end

  context 'admin user' do
    before :each do
      @user = User.make!
      sign_in @user
    end

    it "should get :index" do
      issues = [issue]

      get :index

      assigns(:issues).should == issues
      response.should have_rendered(:index)
    end

    it 'should get :show for a logged in user' do
      get :show, id: issue

      assigns(:issue).should == issue
      assigns(:promises_by_party).should_not be_nil
      response.should have_rendered(:show)
    end

    it "shows also non-published issues for the next/previous links" do
      t1 = Issue.make! title: 'aaaa1', :published => true
      t2 = Issue.make! title: 'aaaa2', :published => true
      t3 = Issue.make! title: 'aaaa3', :published => false

      get :show, id: t2

      assigns(:previous_issue).should eq t1
      assigns(:next_issue).should eq t3
    end


    it 'should get :new' do
      get :new

      response.should have_rendered(:new)

      session[:issue_step].should == 'categories'
      assigns(:categories).should_not be_nil
    end

    it 'edit redirects to the categories step if no step was specified' do
      get :edit, id: issue

      response.should redirect_to(edit_issue_step_path(issue, step: 'categories'))
    end

    it 'edits the vote step if specified' do
      get :edit, id: issue, step: 'votes'

      response.should have_rendered(:edit)
      assigns(:votes_and_connections).should_not be_nil
    end

    it 'edits the promises step if specified' do
      get :edit, id: issue, step: 'promises'

      response.should have_rendered(:edit)
      assigns(:promises_by_party).should_not be_nil
    end

    it 'edits the cateogires step if specified' do
      get :edit, id: issue, step: 'categories'

      response.should have_rendered(:edit)
      assigns(:categories).should_not be_nil
    end

    it 'edits the topics step if specified' do
      get :edit, id: issue, step: 'topics'

      response.should have_rendered(:edit)
      assigns(:topics).should_not be_nil
    end

    it "should create a new issue with a name" do
      post :create, issue: { title: 'More Cowbell' }, finish: true

      Issue.count.should == 1

      issue = assigns(:issue)
      issue.should be_kind_of(Issue)

      response.should redirect_to(issue_path(issue))
    end

    it 'should render new if save was unsuccessful' do
      post :create, issue: {title: ''}, finish: true

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

      it 'should re-edit topics if update was unsuccessful' do
        pending "can this actually happen?"
      end
    end

    context 'destroy' do
      it 'should destroy the issue' do
        delete :destroy, id: issue

        Issue.count.should == 0
        response.should redirect_to(issues_url)
      end
    end

    context "next" do
      it "should show the promises step when hit next from create" do
        post :create, issue: { title: "Less Cowbell!" }

        issue = assigns(:issue)
        issue.should be_kind_of(Issue)
        issue.last_updated_by.should == @user

        expected_url = edit_issue_step_path(id: issue, step: 'promises')
        response.should redirect_to(expected_url)
      end

      it "should show votes step when hit next from promises" do
        session[:issue_step] = 'promises'

        put :update, issue: issue_params(issue), id: issue

        assigns(:issue).should == issue
        session[:issue_step].should == 'votes'

        response.should redirect_to(edit_issue_step_url(issue, step: 'votes'))
      end

      it "should show topics step when hit next from votes" do
        session[:issue_step] = 'votes'

        put :update, issue: issue_params(issue), id: issue

        session[:issue_step].should == 'topics'
        assigns(:issue).should == issue
        response.should redirect_to(edit_issue_step_url(step: 'topics' ))
      end
    end

    context "previous" do
      it "should show votes step when hit previous from topics" do
        session[:issue_step] = 'topics'

        put :update, previous: true, issue: issue_params(issue), id: issue

        session[:issue_step].should == 'votes'
        assigns(:issue).should == issue
        response.should redirect_to edit_issue_step_url(issue, step: 'votes' )
      end

      it "should show promises when hit previous from votes" do
        session[:issue_step] = 'votes'

        put :update, previous: true, issue: issue_params(issue), id: issue

        session[:issue_step].should == 'promises'
        assigns(:issue).should == issue
        response.should redirect_to edit_issue_step_url(issue, step: 'promises')
      end

      it "should show the categories step when hit previous from promises" do
        session[:issue_step] = 'promises'

        put :update, previous: true, issue: issue_params(issue), id: issue

        session[:issue_step] = 'categories'
        assigns(:issue).should == issue
        response.should redirect_to edit_issue_step_url(issue, step: 'categories')
      end
    end

    context "finish" do
      it "should save and redirect to issue when hit finish from edit step" do
        session[:issue_step] = 'votes'

        put :update, finish: true, issue: issue_params(issue), id: issue

        assigns(:issue).should == issue
        response.should redirect_to issue_path(issue)
      end
    end

    context "update" do
      it "should update the published state" do
        put :update, finish: true, issue: issue_params(issue).merge('published' => 'true'), id: issue

        issue = assigns(:issue)
        issue.should be_published

        response.should redirect_to issue_path(issue)
      end

      it 'sets last_updated_by when published state changes' do
        put :update, issue: issue_params(issue).merge('published' => 'true'), id: issue

        issue = assigns(:issue)
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when attributes change' do
        put :update, issue: issue_params(issue).merge('title' => 'changed-title'), id: issue

        issue = assigns(:issue)
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when categories are changed' do
        category = Category.make!

        put :update, issue: issue_params(issue).merge('category_ids' => [category.id]), id: issue

        issue = assigns(:issue)
        issue.categories.should == [category]
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when promises are changed' do
        promise = Promise.make!

        put :update, issue: issue_params(issue).merge('promise_ids' => [promise.id]), id: issue

        issue = assigns(:issue)
        issue.promises.should == [promise]
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when topics are changed' do
        topic = Topic.make!

        put :update, issue: issue_params(issue).merge('topic_ids' => [topic.id]), id: issue

        issue = assigns(:issue)
        issue.topics.should == [topic]
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when vote connections are removed' do
        connection = VoteConnection.create(:vote => Vote.make!, matches: true, weight: 1, comment: 'hello', description: 'world')
        issue.vote_connections = [connection]

        votes = votes_params(issue.vote_connections)
        votes[connection.vote_id][:direction] = 'unrelated'

        put :update, votes: votes, id: issue

        issue = assigns(:issue)
        issue.vote_connections.should be_empty
        issue.last_updated_by.should == @user
      end

      it 'ignores unrelated votes' do
        issue.vote_connections = []

        vote = Vote.make!
        votes = {
          vote.id => {
            :direction => "unrelated",
            :weight => "1.0",
            :description => "",
            :comment => ""}
         }

        put :update, votes: votes, id: issue

        issue = assigns(:issue)
        issue.vote_connections.should be_empty
        issue.last_updated_by.should be_nil
      end


      it 'sets last_updated_by when vote connections are added' do
        vote = Vote.make!
        issue.vote_connections = []

        votes_param = {vote.id => {direction: 'for', weight: '1.0', comment: 'hello', description: 'world'}}
        put :update, votes: votes_param, id: issue

        issue = assigns(:issue)
        issue.vote_connections.size.should == 1
        issue.last_updated_by.should == @user
      end

      it 'sets last_updated_by when vote connections are updated' do
        connection = VoteConnection.create(:vote => Vote.make!, matches: true, weight: 1, comment: 'hello', description: 'world')
        issue.vote_connections = [connection]


        votes = votes_params(issue.vote_connections)
        votes[connection.vote_id][:weight] = '2.0'

        put :update, votes: votes, id: issue

        issue = assigns(:issue)

        issue.vote_connections.size.should == 1
        issue.vote_connections.first.weight.should == 2.0
        issue.last_updated_by.should == @user
      end

      it 'does not set last_updated_by when update is called with no change to attributes' do
        issue.last_updated_by = other_user = User.make!
        issue.save!

        put :update, issue: issue_params(issue), id: issue

        issue = assigns(:issue)
        issue.last_updated_by.should == other_user
      end

      it 'does not set last_updated_by when update is called with no change to vote connections' do
        issue.last_updated_by = other_user = User.make!
        issue.save!

        vote_connection = VoteConnection.create(matches: true, weight: 1, comment: 'foo', description: 'bar', vote: Vote.make!)
        issue.vote_connections = [vote_connection]

        put :update, votes: votes_params(issue.vote_connections), id: issue

        issue = assigns(:issue)
        issue.last_updated_by.should == other_user
      end
    end

    describe "the issue_steps parameter" do
      it "should be set when editing an issue" do
        get :edit, id: issue, step: 'categories'
        assigns(:issue_steps).should_not be_nil
      end

      it "should not be set when creating a new issue" do
        get :new
        assigns(:issue_steps).should be_nil
      end
    end
  end # admin user

  context 'normal user' do
    it 'should get :show if the issue is published' do
      issue.update_attributes! published: true

      get :show, id: issue

      response.should have_rendered(:show)

      assigns(:issue).should == issue
      assigns(:promises_by_party).should_not be_nil
    end

    it 'should get :votes if the issue is published' do
      issue.update_attributes! published: true

      get :votes, id: issue

      response.should have_rendered(:votes)
      assigns(:party_groups).should be_kind_of(Enumerable)
    end

    it 'should redirect :show to the front page if the issue is not published' do
      get :show, id: issue
      response.should redirect_to(new_user_session_path)
    end

    it 'should redirect :votes to the front page if the issue is not published' do
      get :votes, id: issue
      response.should redirect_to(new_user_session_path)
    end

    context "with rendered views" do
      render_views

      it "should render :show" do
        get :show, id: Issue.make!(:published => true)
        response.should have_rendered(:show)
      end
    end

    context "show" do
      it "should set variables for previous and next issue" do
        # TODO: move to model spec?

        t1 = Issue.make! title: 'aaaa1', :published => true
        t2 = Issue.make! title: 'aaaa2', :published => true
        t3 = Issue.make! title: 'aaaa3', :published => true

        get :show, id: t2

        assigns(:previous_issue).should eq t1
        assigns(:next_issue).should eq t3
      end

      it "ignores non-published issues for the next/previous links" do
        # TODO: move to model spec?

        t1 = Issue.make! title: 'aaaa1', :published => true
        t2 = Issue.make! title: 'aaaa2', :published => true
        t3 = Issue.make! title: 'aaaa3', :published => false

        get :show, id: t2

        assigns(:previous_issue).should eq t1
        assigns(:next_issue).should be_nil
      end
    end
  end # normal user

end
