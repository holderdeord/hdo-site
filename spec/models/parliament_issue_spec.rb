require 'spec_helper'

describe ParliamentIssue do
  let(:parliament_issue) { ParliamentIssue.make! }

  it 'has a valid blueprint' do
    parliament_issue.should be_valid
  end

  it 'humanizes the status string' do
    ParliamentIssue.make!(status: 'ikke_behandlet').status_text.should == 'Ikke behandlet'
  end

  it 'knows if the issue was processed' do
    ParliamentIssue.make!(status: "behandlet").should be_processed
  end

  it 'can add categories' do
    c = Category.make!

    parliament_issue.categories << c
    parliament_issue.categories.size.should == 1

    c.parliament_issues.size.should == 1
  end

  it "won't add the same category twice" do
    c = Category.make!

    parliament_issue.categories << c
    parliament_issue.categories << c

    parliament_issue.categories.size.should == 1
  end

  it 'can add votes' do
    v = Vote.make!

    parliament_issue.votes << v
    parliament_issue.votes.size.should == 1
  end

  it "won't add the same vote twice" do
    v = Vote.make!

    parliament_issue.votes << v
    parliament_issue.votes << v

    parliament_issue.votes.size.should == 1
  end
end
