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
  end

  describe 'GET #representative' do
    it 'assigns the requested representative' do
      get :representative, id: representative.slug
      response.should be_ok

      assigns(:representative).should be_kind_of(Representative)
    end
  end
end
