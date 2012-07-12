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

  it "should be personal if counts are present" do
    vote.for_count     = 89
    vote.against_count = 80
    vote.absent_count  = 0

    vote.should be_personal
  end

  it "should be personal if it's unanimously for" do
    vote.for_count     = 169
    vote.against_count = 0
    vote.absent_count  = 0

    vote.should be_personal
  end

  it "should be personal if it's unanimously against" do
    vote.for_count     = 0
    vote.against_count = 169
    vote.absent_count  = 0

    vote.should be_personal
  end

  it "should be personal if all are absent" do
    vote.for_count     = 0
    vote.against_count = 0
    vote.absent_count  = 169

    vote.should be_personal
  end

  it "should not be personal if no counts were registered" do
    vote.for_count     = 0
    vote.against_count = 0
    vote.absent_count  = 0

    vote.should_not be_personal
  end

  it "should have a personal scope" do
    a = Vote.make! :for_count => 89, :against_count => 80, :absent_count => 0
    b = Vote.make! :for_count => 169, :against_count => 0, :absent_count => 0
    c = Vote.make! :for_count => 0, :against_count => 169, :absent_count => 0
    d = Vote.make! :for_count => 0, :against_count => 0, :absent_count => 169
    e = Vote.make! :for_count => 0, :against_count => 0, :absent_count => 0

    Vote.personal.should == [a, b, c, d]
  end
end
