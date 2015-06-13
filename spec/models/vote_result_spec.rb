require 'spec_helper'

describe VoteResult do
  it 'has a valid blueprint' do
    VoteResult.make.should be_valid
  end

  it 'is invalid if the same representative is added for the same vote' do
    rep = Representative.make!

    valid   = VoteResult.make!(representative: rep)
    invalid = VoteResult.make(representative: rep, vote: valid.vote)

    invalid.should be_invalid
  end

  it 'has methods for vote result' do
    v = VoteResult.make

    v.result = 0

    v.should be_absent
    v.should_not be_present
    v.should_not be_for
    v.should_not be_against

    v.result = 1

    v.should be_for
    v.should be_present
    v.should_not be_against
    v.should_not be_absent

    v.result = -1

    v.should be_against
    v.should be_present
    v.should_not be_for
    v.should_not be_absent
  end

  it 'knows if it is a rebel vote' do
    rep1 = Representative.make!(:full)

    rep2 = Representative.make!
    rep2.party_memberships.make!(party: rep1.current_party)

    rep3 = Representative.make!
    rep3.party_memberships.make!(party: rep1.current_party)

    rep4 = Representative.make!
    rep4.party_memberships.make!(party: rep1.current_party)

    vote = Vote.make!(vote_results: [])

    party_line1 = vote.vote_results.make!(representative: rep1, result: 1)
    party_line2 = vote.vote_results.make!(representative: rep2, result: 1)
    absent      = vote.vote_results.make!(representative: rep3, result: 0)
    rebel       = vote.vote_results.make!(representative: rep4, result: -1)

    party_line1.should_not be_rebel
    party_line2.should_not be_rebel
    absent.should_not be_rebel
    rebel.should be_rebel
  end

  it 'is not a rebel vote if an equal number is absent' do
    rep1 = Representative.make!(:full)
    rep2 = Representative.make!
    rep3 = Representative.make!

    rep2.party_memberships.make!(party: rep1.current_party)
    rep3.party_memberships.make!(party: rep1.current_party)

    vote    = Vote.make!(vote_results: [])
    absent  = vote.vote_results.make!(representative: rep1, result: 0)
    against = vote.vote_results.make!(representative: rep2, result: 1)
    support = vote.vote_results.make!(representative: rep3, result: -1)

    absent.should_not be_rebel
    against.should_not be_rebel
    absent.should_not be_rebel
  end

  it 'has a human text representation of the result' do
    I18n.with_locale :nb do
      VoteResult.make(:result => 1).human.should == "For"
      VoteResult.make(:result => 0).human.should == "Ikke til stede"
      VoteResult.make(:result => -1).human.should == "Mot"
    end
  end

  it 'has icons' do
    I18n.with_locale :nb do
      VoteResult.make(:result => 1).icon.should == "plus-sign"
      VoteResult.make(:result => 0).icon.should == "question-sign"
      VoteResult.make(:result => -1).icon.should == "minus-sign"
    end
  end

  it 'has alerts' do
    I18n.with_locale :nb do
      VoteResult.make(:result => 1).alert.should == "alert-success"
      VoteResult.make(:result => 0).alert.should == "alert-info"
      VoteResult.make(:result => -1).alert.should == "alert-error"
    end
  end

end
