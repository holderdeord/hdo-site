# encoding: utf-8

require 'spec_helper'

describe ValenceIssueExplanation do
  it 'has a valid blueprint' do
    e = ValenceIssueExplanation.make!
    e.should be_valid
  end

  it 'is invalid without parties' do
    e = ValenceIssueExplanation.make parties: []

    e.should_not be_valid
  end

  it 'can uncapitalize the title' do
    e = ValenceIssueExplanation.make(title: 'Ærlig TALT')

    e.downcased_title.should == 'ærlig TALT'
  end
end
