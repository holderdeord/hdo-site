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

  it "should have a non_personal scope" do
    a = Vote.make! :personal => true
    b = Vote.make! :personal => false

    Vote.non_personal.should == [b]
  end

  it "it knows if it has results" do
    with    = Vote.make!
    without = Vote.make!(:vote_results => [])

    with.should have_results
    without.should_not have_results
  end

  it 'knows if results were inferred' do
    inferred     = Vote.make!(:personal => false)
    not_inferred = Vote.make!(:personal => false, :vote_results => [])

    inferred.should be_inferred
    not_inferred.should_not be_inferred
  end

  it 'knows if a result is non-personal' do
    Vote.make!(:personal => false).should be_non_personal
  end
end
