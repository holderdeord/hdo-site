require 'spec_helper'

describe ParliamentIssuesController do

  it 'can show index' do
    get :index

    assigns(:search).should be_kind_of(Hdo::Search::ParliamentIssues)
  end

  it 'renders promises#index as csv' do
    get :index, format: :csv
    response.should be_success
  end

  it 'renders promises#index as tsv' do
    get :index, format: :tsv
    response.should be_success
  end

  it 'can show an issue' do
    issue = ParliamentIssue.make!

    get :show, id: issue

    assigns(:parliament_issue).should == issue
    response.should have_rendered(:show)
  end

end
