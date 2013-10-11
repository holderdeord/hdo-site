require 'spec_helper'

describe VoteConnection do
  let(:vote_connection) { VoteConnection.make! }

  it 'should have a valid blueprint' do
    vote_connection.should be_valid
  end

  it 'should be invalid without a vote' do
    VoteConnection.make(:vote => nil).should be_invalid
  end

  it 'should be invalid without a issue' do
    VoteConnection.make(:issue => nil).should be_invalid
  end
end
