# encoding: utf-8
require 'spec_helper'

describe Issue do
  let(:blank_issue) { Issue.new }
  let(:valid_issue) { Issue.make! }

  it "is invalid without a title" do
    t = blank_issue

    t.should_not be_valid
    t.title = "foo"
    t.should be_valid
  end

  it "can associate categories" do
    a = Category.make!
    b = Category.make!

    t = valid_issue

    t.categories << a
    t.categories << b

    t.categories.map(&:name).should == [a.name, b.name]

    t.should be_valid
  end

  it "won't add the same category twice" do
    cat = Category.make!

    valid_issue.categories << cat
    valid_issue.categories << cat

    valid_issue.categories.size.should == 1
  end

  it "can associate promises" do
    valid_issue.promises << Promise.make!
    valid_issue.promises.first.body.should_not be_empty
  end

  it "won't add the same promise twice" do
    promise = Promise.make!

    valid_issue.promises << promise
    valid_issue.promises << promise

    valid_issue.promises.size.should == 1
  end

  it "can associate topics" do
    topic = Topic.make!

    valid_issue.topics << topic
    valid_issue.topics.first.should == topic
  end

  it "won't add the same topic twice" do
    topic = Topic.make!

    valid_issue.topics << topic
    valid_issue.topics << topic

    valid_issue.topics.size.should == 1
  end

  it "can associate votes with a vote direction" do
    vote = Vote.make!
    issue = Issue.make!(:vote_connections => [])

    issue.vote_connections.create!(:vote => vote, :matches => true)
    issue.votes.should == [vote]

    issue.connection_for(vote).should_not be_nil
  end

  it 'destroys vote connections when destroyed' do
    issue = Issue.make!
    issue.vote_connections.size.should == VoteConnection.count

    issue.destroy
    VoteConnection.count.should == 0
  end

  it "has a unique title" do
    Issue.make!(:title => 'a')
    Issue.make(:title => 'a').should_not be_valid
  end

  it "has a stats object" do
    valid_issue.stats.should be_kind_of(Hdo::Stats::VoteScorer)
  end

  it 'caches the stats object' do
    Hdo::Stats::VoteScorer.should_receive(:new).once

    Issue.find(valid_issue.id).stats # 1 - not cached
    Issue.find(valid_issue.id).stats # 2 - cached
  end

  it 'deletes the cached stats on save' do
    Hdo::Stats::VoteScorer.should_receive(:new).twice

    Issue.find(valid_issue.id).stats # 1 - not cached
    Issue.find(valid_issue.id).stats # 2 - cached

    valid_issue.vote_connections.create! :vote => Vote.make!, :matches => true

    Issue.find(valid_issue.id).stats # 3 - no longer cached
  end

  it 'correctly downcases a title with non-ASCII characters' do
    Issue.make(:title => "Styrke boligsparing for ungdom (BSU)").downcased_title.should == "styrke boligsparing for ungdom (BSU)"
  end

  it 'finds the latest issues based on vote time' do
    t1 = Issue.make!
    t2 = Issue.make!
    t3 = Issue.make!

    t1.vote_connections.map { |e| e.vote.update_attributes!(:time => 3.days.ago) }
    t2.vote_connections.map { |e| e.vote.update_attributes!(:time => 2.days.ago) }
    t3.vote_connections.map { |e| e.vote.update_attributes!(:time => 1.day.ago) }

    Issue.vote_ordered.should == [t3, t2, t1]
  end

  it 'has a #published_text' do
    t = Issue.make!
    t.published_text.should be_kind_of(String)
  end
end
