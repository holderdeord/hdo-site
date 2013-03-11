require 'spec_helper'

describe PartyComment do
  it "has a valid blueprint" do
    PartyComment.make!.valid?
  end

  it "doesn't allow the same party to comment the same issue more than once" do
    party = Party.make!
    issue = Issue.make!
    PartyComment.make! party: party, issue: issue

    PartyComment.make(party: party, issue: issue).should_not be_valid
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
end
