require 'spec_helper'

describe ParliamentIssuesController do

  it 'can show index' do
    get :index

    assigns(:search).should be_kind_of(Hdo::Search::ParliamentIssues)
  end

  it 'can show an issue' do
    issue = ParliamentIssue.make!

    get :show, id: issue

    assigns(:parliament_issue).should == issue
    response.should have_rendered(:show)
  end

end
