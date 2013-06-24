require 'spec_helper'

describe IssueOverride do
  it 'has a valid blueprint' do
    IssueOverride.make.should be_valid
  end

  it 'validates the kind' do
    IssueOverride.make(kind: 'promise').should be_valid
    IssueOverride.make(kind: 'position').should be_valid
    IssueOverride.make(kind: 'foobar').should_not be_valid
  end

  it 'validates the score' do
    IssueOverride.make(score: -1).should_not be_valid
    IssueOverride.make(score: 0).should be_valid
    IssueOverride.make(score: 50).should be_valid
    IssueOverride.make(score: 100).should be_valid
    IssueOverride.make(score: 101).should_not be_valid
  end

  it 'is destroyed when the issue is destroyed'
end
