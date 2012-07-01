require 'spec_helper'

describe Topic do
  let(:blank_topic) { Topic.new }
  let(:valid_topic) { Topic.new(:title => "Topic Title") }

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

    vote_direction = VoteDirection.create!(:vote => vote, :topic => valid_topic, :matches => true)
    valid_topic.votes.should == [vote]
  end

  it "has a stats object" do
    valid_topic.stats.should be_kind_of(Hdo::Stats::TopicCounts)
  end
end
