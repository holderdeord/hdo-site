require 'spec_helper'

describe VotesController do
  render_views

  it "should set the votes variable on index" do
    get :index

    assigns(:votes).should_not be_nil
  end

  it "should return the vote on get" do
    vote = Vote.make!
    ParliamentSession.create!(start_date: vote.time - 5.days, end_date: vote.time + 5.day)

    get :show, id: vote

    assigns(:vote).should == vote
  end

  it "should redirect to the proposition if source is a rebel tweet and there's only one proposition in the vote" do
    vote_a = Vote.make!(:propositions => [Proposition.make!])
    vote_b = Vote.make!(:propositions => [Proposition.make!, Proposition.make!])

    get :show, id: vote_a, src: 'rtw'
    response.should redirect_to(vote_a.propositions.first)

    get :show, id: vote_b
    response.should be_ok
  end
end
