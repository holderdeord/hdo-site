require 'spec_helper'

describe WidgetsController do
  let(:published_issue)   { Issue.make!(status: 'published') }
  let(:in_progress_issue) { Issue.make!(status: 'in_progress') }
  let(:party) { Party.make! }
  let(:representative) { Representative.make! }

  describe 'GET #issue' do
    it 'assigns the requested issue' do
      get :issue, id: published_issue
      response.should be_ok

      assigns(:issue).should be_kind_of(Issue)
    end

    it 'does not find non-published issues' do
      get :issue, id: in_progress_issue
      response.should be_not_found

      assigns(:issue).should be_nil
    end

    it 'redirects slugged URLs to the correct URL' do
      get :issue, id: published_issue.slug

      response.should redirect_to(widget_issue_url(published_issue))
      response.status.should == 301
    end
  end

  describe 'GET #party' do
    it 'assigns the requested party' do
      get :party, id: party
      response.should be_ok

      assigns(:party).should be_kind_of(Party)
    end

    it 'assigns the requested issues' do
      published_issue.valence_issue_explanations.create!(title: "foo", parties: [party])

      get :party, id: party, issues: published_issue.id
      response.should be_ok

      assigns(:party).should be_kind_of(Party)
      assigns(:issues).should == [published_issue]
    end
  end

  describe 'GET #topic' do
    let(:issues) { [Issue.make!(:published), Issue.make!(:published)] }
    let(:promises) { [Promise.make!, Promise.make! ]}

    it 'assigns the requested issues and promises' do
      get :topic, promises: {'Topic' => promises.map(&:id).join(',') },
                  issues: issues.map(&:id).join(',')

      response.should be_ok

      assigns(:issues).should == issues
      assigns(:promise_groups).should == [['Topic', promises]]
    end
  end

  describe 'GET #promises' do
    let(:parties) { [Party.make!] }
    let(:promises) { [Promise.make!(parties: parties), Promise.make!(parties: parties)] }

    it 'assigns the requested promises' do
      get :promises, promises: promises.map(&:id).join(',')

      response.should be_ok
      assigns(:promise_groups).to_a.should == [[parties, promises]]
      assigns(:parliament_period_name).should == '2009-2013'
    end
  end

  describe 'GET #configuration' do
    let(:auth) do
      ActionController::HttpAuthentication::Basic.encode_credentials(*Hdo::BasicAuth.users.first)
    end

    it 'expects basic auth' do
      get :configure
      response.status.should == 401
    end

    it 'ignores basic auth if the user is signed in' do
      sign_in User.make!

      get :configure
      response.should be_success
    end

    it 'assigns published issues' do
      published, issue = Issue.make!(:published), Issue.make!

      request.env['HTTP_AUTHORIZATION'] = auth
      get :configure

      response.should be_success
      assigns(:issues).should == [published]
    end
  end

  describe 'GET #load' do
    render_views

    it 'renders the load script' do
      get :load, format: :js

      response.should be_ok
    end
  end
end
