require 'spec_helper'

describe PropositionConnection do
  let(:vote_connection) { PropositionConnection.make! }

  it 'should have a valid blueprint' do
    vote_connection.should be_valid
  end

  it 'should be invalid without a proposition' do
    PropositionConnection.make(proposition: nil).should be_invalid
  end

  it 'should be invalid without a issue' do
    PropositionConnection.make(issue: nil).should be_invalid
  end

  it "uses the propositions's vote if present" do
    prop = Proposition.make!
    vote = Vote.make!(:propositions => [prop])

    pc = PropositionConnection.make!(:proposition => prop)
    pc.vote.should == vote
  end

  it 'is invalid if the proposition has several votes but no vote_id is set' do
    prop = Proposition.make!(votes: [Vote.make!, Vote.make!])

    pc = PropositionConnection.make(proposition: prop)
    pc.should_not be_valid
    pc.errors[:proposition].should_not be_empty
  end

  it 'uses the overriden vote if set' do
    vote = Vote.make!

    pc = PropositionConnection.make!(vote: vote)
    pc.vote.should == vote
  end
end
