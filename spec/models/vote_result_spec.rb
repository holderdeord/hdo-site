require 'spec_helper'

describe VoteResult do
  it 'has a valid blueprint' do
    VoteResult.make.should be_valid
  end

  it 'is invalid if the same representative is added for the same vote' do
    rep = Representative.make!

    valid = VoteResult.make!(:representative => rep)
    invalid = VoteResult.make(:representative => rep, :vote => valid.vote)

    invalid.should be_invalid
  end
end
