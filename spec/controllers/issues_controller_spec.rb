require 'spec_helper'

describe IssuesController do

  it 'can show index' do
    issue = Issue.make!

    get :index

    assigns(:issues).should == [issue]
  end

  it 'can show an issue' do
    issue = Issue.make!

    get :show, id: issue

    assigns(:issue).should == issue
    response.should have_rendered(:show)
  end

end
