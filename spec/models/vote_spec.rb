require 'spec_helper'

describe Vote do
  let(:vote) { Vote.make }

  it "should have a valid blueprint" do
    vote.should be_valid
  end

  it "should be invalid with no issues" do
    v = Vote.make(:issues => [])
    v.should_not be_valid
  end

  it "should be invalid without a time" do
    v = Vote.make(:time => nil)
    v.should_not be_valid
  end

  it "should have a stats object" do
    vote.stats.should be_kind_of(Hdo::Stats::VoteCounts)
  end

  it "should have a personal scope" do
    a = Vote.make! :personal => true
    b = Vote.make! :personal => false

    Vote.personal.should == [a]
  end
end
