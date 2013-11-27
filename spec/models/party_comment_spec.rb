require 'spec_helper'

describe PartyComment do
  it "has a valid blueprint" do
    PartyComment.make!
  end

  it "doesn't allow the same party to comment the same issue and parliament period twice" do
    party  = Party.make!
    issue  = Issue.make!
    period = ParliamentPeriod.make!

    PartyComment.make!(party: party, issue: issue, parliament_period: period)
    PartyComment.make(party: party, issue: issue, parliament_period: period).should_not be_valid
  end

  it "allows different parties to comment the same issue" do
    issue = Issue.make!
    PartyComment.make! issue: issue

    PartyComment.make(issue: issue).should be_valid
  end

  it "allows the same party to comment multiple issues" do
    party = Party.make!
    PartyComment.make!(party: party)

    PartyComment.make(party: party).should be_valid
  end

  it 'is invalid without a parliament period' do
    PartyComment.make(parliament_period: nil).should_not be_valid
  end

  it 'is invalid without a party' do
    PartyComment.make(party: nil).should_not be_valid
  end

  it 'is invalid without an issue' do
    PartyComment.make(issue: nil).should_not be_valid
  end
end
