require 'spec_helper'

describe Admin::IssuesController do
  let(:issue)   { Issue.make!  }
  let(:user)    { User.make! role: 'superadmin'  }
  before(:each) { sign_in user }

  def issue_params(issue)
    issue.as_json except: [:created_at, :id, :last_updated_by_id, :slug, :updated_at, :published_at]
  end

  def proposition_params(connections)
    params = {}

    connections.each do |connection|
      params[connection.proposition_id] = [{
        :connected   => true,
        :comment     => connection.comment,
        :title       => connection.title
      }]
    end

    params
  end

  context "read only mode" do
    before do
      AppConfig.any_instance.stub(:read_only).and_return(true)
    end

    it "redirects from edit if read_only" do
      get :edit, id: Issue.make!
      response.code.should eq '307'
    end

    it "redirects from new if read_only" do
      get :new
      response.code.should eq '307'
    end

    it "redirects from update if read_only" do
      put :update, id: Issue.make!
      response.code.should eq '307'
    end

    it "redirects from create" do
      post :create
      response.code.should eq '307'
    end
  end

  it "should get :index" do
    issues = [issue]

    get :index
    response.should be_ok

    assigns(:issues_by_status).should == {'in_progress' => [issue]}
    response.should have_rendered(:index)
  end

  it 'should get :new' do
    get :new
    response.should have_rendered(:edit)
  end

  it 'should get :show if the request is an XHR' do
    get :show, id: issue
    response.status.should == 406

    xhr :get, :show, id: issue
    response.should have_rendered(:show)
  end

  it "should create a new issue with a name" do
    post :create, issue: { title: 'More Cowbell' }

    Issue.count.should == 1

    issue = assigns(:issue)
    issue.should be_kind_of(Issue)

    response.should be_success
  end

  it 'should fails if save was unsuccessful' do
    post :create, issue: {title: ''}
    response.should_not be_success
  end

  context 'destroy' do
    it 'should destroy the issue' do
      delete :destroy, id: issue

      Issue.count.should == 0
      response.should redirect_to(admin_issues_url)
    end
  end

  context "finish" do
    before do
      PageCache.should_receive(:expire_issue).with instance_of(Issue)
    end

    it "should save and redirect to issue when hit finish from edit step" do
      put :update, issue: issue_params(issue), id: issue

      assigns(:issue).should == issue
      response.should be_success
    end

    it "should update the published state" do
      put :update, issue: issue_params(issue).merge('status' => 'published'), id: issue

      issue = assigns(:issue)
      issue.should be_published

      response.should be_success
    end
  end

  context "update" do
    it 'sets last_updated_by when published state changes' do
      put :update, issue: issue_params(issue).merge('status' => 'published'), id: issue

      issue = assigns(:issue)
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when attributes change' do
      put :update, issue: issue_params(issue).merge('title' => 'changed-title'), id: issue

      issue = assigns(:issue)
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when categories are changed' do
      category = Category.make!

      put :update, issue: issue_params(issue).merge('category_ids' => [category.id]), id: issue

      issue = assigns(:issue)
      issue.categories.should == [category]
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when promises are changed' do
      promise = Promise.make!

      put :update, promises: {promise.id => {status: 'related'}}, id: issue

      issue = assigns(:issue)
      issue.promises.should == [promise]
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when tags are changed' do
      put :update, issue: issue_params(issue).merge('tag_list' => "foo"), id: issue

      issue = assigns(:issue)
      issue.tag_list.should == ["foo"]
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when proposition connections are removed' do
      connection = PropositionConnection.create(:proposition => Proposition.make!, comment: 'hello', title: 'world')
      issue.proposition_connections = [connection]

      propositions = proposition_params(issue.proposition_connections)
      propositions[connection.proposition_id].first[:connected] = nil

      put :update, propositions: propositions, id: issue

      issue = assigns(:issue)
      issue.proposition_connections.should be_empty
      issue.last_updated_by.should == user
    end

    it 'ignores non-connected propositions' do
      issue.proposition_connections = []

      prop = Proposition.make!(:votes => [Vote.make!])
      propositions = {
        prop.id => [{
          connected: nil,
          title: "",
          comment: ""
        }]
      }

      put :update, propositions: propositions, id: issue

      issue = assigns(:issue)
      issue.proposition_connections.should be_empty
      issue.last_updated_by.should be_nil
    end

    it 'sets last_updated_by when proposition connections are added' do
      prop = Proposition.make!
      issue.proposition_connections = []

      proposition_params = {prop.id => [{connected: 'true', comment: 'hello', title: 'world'}]}
      put :update, propositions: proposition_params, id: issue

      issue = assigns(:issue)
      issue.proposition_connections.size.should == 1
      issue.last_updated_by.should == user
    end

    it 'sets last_updated_by when proposition connections are updated' do
      connection = PropositionConnection.create(:proposition => Proposition.make!, comment: 'hello', title: 'world')
      issue.proposition_connections = [connection]

      propositions = proposition_params(issue.proposition_connections)
      propositions[connection.proposition_id].first[:comment] = 'goodbye'

      put :update, propositions: propositions, id: issue

      issue = assigns(:issue)

      issue.proposition_connections.size.should == 1
      issue.last_updated_by.should == user
    end

    it 'does not set last_updated_by when update is called with no change to attributes' do
      issue.last_updated_by = other_user = User.make!
      issue.save!

      put :update, issue: issue_params(issue), id: issue

      issue = assigns(:issue)
      issue.last_updated_by.should == other_user
    end

    it 'does not set last_updated_by when update is called with no change to proposition connections' do
      issue.last_updated_by = other_user = User.make!
      issue.save!

      proposition_connection = PropositionConnection.create(comment: 'foo', title: 'bar', proposition: Proposition.make!)
      issue.proposition_connections = [proposition_connection]

      put :update, propositions: proposition_params(issue.proposition_connections), id: issue

      issue = assigns(:issue)
      issue.last_updated_by.should == other_user
    end
  end

  context 'as contributor' do
    let(:user) { User.make!(role: 'contributor')}
    before(:each) { sign_in user }

    it 'disallows issue creation' do
      get :new

      flash.alert.should_not be_empty
      response.should redirect_to admin_root_path
    end

    it 'disallows issue editing' do
      get :edit, id: issue

      flash.alert.should_not be_empty
      response.should redirect_to admin_root_path
    end
  end
end
