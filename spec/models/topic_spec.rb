# encoding: utf-8
require 'spec_helper'

describe Topic do
  let(:blank_topic) { Topic.new }
  let(:valid_topic) { Topic.make! }

  it "is invalid without a title" do
    t = blank_topic

    t.should_not be_valid
    t.title = "foo"
    t.should be_valid
  end

  it "can associate categories" do
    a = Category.make!
    b = Category.make!

    t = valid_topic

    t.categories << a
    t.categories << b

    t.categories.map(&:name).should == [a.name, b.name]

    t.should be_valid
  end

  it "can associate promises" do
    valid_topic.promises << Promise.make!
    valid_topic.promises.first.body.should_not be_empty
  end

  it "can associate votes with a vote direction" do
    vote = Vote.make!
    topic = Topic.make!(:vote_connections => [])

    topic.vote_connections.create!(:vote => vote, :matches => true)
    topic.votes.should == [vote]

    topic.connection_for(vote).should_not be_nil
  end

  it 'destroys vote connections when destroyed' do
    topic = Topic.make!
    topic.vote_connections.size.should == VoteConnection.count

    topic.destroy
    VoteConnection.count.should == 0
  end

  it "has a unique title" do
    Topic.make!(:title => 'a')
    Topic.make(:title => 'a').should_not be_valid
  end

  it "has a stats object" do
    valid_topic.stats.should be_kind_of(Hdo::Stats::VoteScorer)
  end

  it 'caches the stats object' do
    Hdo::Stats::VoteScorer.should_receive(:new).once

    Topic.find(valid_topic.id).stats
    Topic.find(valid_topic.id).stats # cached
  end

  it 'deletes the cached stats on save' do
    Hdo::Stats::VoteScorer.should_receive(:new).twice

    Topic.find(valid_topic.id).stats
    Topic.find(valid_topic.id).stats # cached

    valid_topic.vote_connections << VoteConnection.make!(:topic => valid_topic)

    Topic.find(valid_topic.id).stats # no longer cached
  end

  it 'correctly downcases a title with non-ASCII characters' do
    Topic.make(:title => "Ærlig").downcased_title.should == "ærlig"
  end
end
