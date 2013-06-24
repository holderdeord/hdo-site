require 'spec_helper'

describe ValenceIssueExplanation do
  it 'has a valid blueprint' do
    e = ValenceIssueExplanation.make!
    e.should be_valid
  end

  it 'cannot belong to non-valence issue' do
    i = Issue.make!
    e = ValenceIssueExplanation.make issue: i

    e.should_not be_valid
  end

  it 'is invalid without parties' do
    e = ValenceIssueExplanation.make parties: []

    e.should_not be_valid
  end

  it 'is invalid without an explanation' do
    e = ValenceIssueExplanation.make explanation: ''

    e.should_not be_valid
  end
end
