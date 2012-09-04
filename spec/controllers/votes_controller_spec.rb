require 'spec_helper'

describe VotesController do
  render_views
  
  it "should set the votes variable on index" do
    get :index

    assigns(:votes).should_not be_nil
  end

  it "should return the vote on get" do
    @vote = Vote.make!

    get :show, :id => @vote

    assigns(:vote).should eq @vote
  end
end
