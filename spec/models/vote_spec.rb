require 'spec_helper'

describe Vote do
  let(:vote) { Vote.make }

  it "has a valid blueprint" do
    vote.should be_valid
  end

  it "is invalid with no issues" do
    v = Vote.make(:parliament_issues => [])
    v.should_not be_valid
  end

  it "is invalid without a time" do
    v = Vote.make(:time => nil)
    v.should_not be_valid
  end

  it 'is invalid without an external id' do
    vote.external_id = nil
    vote.should_not be_valid
  end

  it 'is invalid without a unique external id' do
    vote.save!

    invalid = Vote.make
    invalid.external_id = vote.external_id

    invalid.should_not be_valid
  end

  it "has a stats object" do
    vote.stats.should be_kind_of(Hdo::Stats::VoteCounts)
  end

  it "has a personal scope" do
    a = Vote.make! :personal => true
    b = Vote.make! :personal => false

    Vote.personal.should == [a]
  end

  it "has a non_personal scope" do
    a = Vote.make! :personal => true
    b = Vote.make! :personal => false

    Vote.non_personal.should == [b]
  end

  it "knows if it has results" do
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

  it 'caches the stats object' do
    vote = Vote.make!

    Hdo::Stats::VoteCounts.should_receive(:new).once

    Vote.find(vote.id).stats # 1 - not cached
    Vote.find(vote.id).stats # 2 - cached
  end

  it 'deletes the cached stats on save' do
    vote = Vote.make!

    Hdo::Stats::VoteCounts.should_receive(:new).twice

    Vote.find(vote.id).stats # 1 - not cached
    Vote.find(vote.id).stats # 2 - cached

    vote.vote_results << VoteResult.make!(:vote => vote)

    Vote.find(vote.id).stats # 3 - no longer cached
  end

  it "won't add the same issue twice" do
    vote = Vote.make :parliament_issues => []
    parliament_issue = ParliamentIssue.make!

    vote.parliament_issues << parliament_issue
    vote.parliament_issues << parliament_issue

    vote.parliament_issues.size.should == 1
    vote.should be_valid
  end

  it 'is invalid if it has the same subject as an existing non-alternate vote' do
    time = 2.days.ago

    valid  = Vote.make!(enacted: true, time: time, subject: 'a')

    Vote.make(
      enacted: true,
      time: time,
      subject: 'a'
    ).should_not be_valid

    Vote.make(
      enacted: false,
      time: time,
      subject: 'a'
    ).should be_valid
  end

  it 'knows if two votes are alternates' do
    time = 2.days.ago
    v1 = Vote.make(for_count: 10, against_count: 20, absent_count: 10, time: time, enacted: true)
    v2 = Vote.make(for_count: 20, against_count: 10, absent_count: 10, time: time, enacted: false)

    unrelated_by_counts1 = Vote.make(time: time, for_count: 5, against_count: 20, absent_count: 10)
    unrelated_by_counts2 = Vote.make(time: time, for_count: 10, against_count: 2, absent_count: 10)
    unrelated_by_counts3 = Vote.make(time: time, for_count: 20, against_count: 10, absent_count: 5)
    unrelated_by_enacted = Vote.make(time: time, for_count: 20, against_count: 10, absent_count: 10, enacted: true)
    unrelated_by_time    = Vote.make(time: 1.month.ago, for_count: 10, against_count: 20)

    v1.should be_alternate_of v2
    v2.should be_alternate_of v1

    v1.should_not be_alternate_of unrelated_by_time
    v1.should_not be_alternate_of unrelated_by_counts1
    v1.should_not be_alternate_of unrelated_by_counts2
    v1.should_not be_alternate_of unrelated_by_counts3
    v1.should_not be_alternate_of unrelated_by_enacted
  end

  it 'finds votes since yesterday' do
    a = Vote.make!(created_at: 25.hours.ago)
    b = Vote.make!(created_at: 23.hours.ago)

    Vote.since_yesterday.should == [b]
  end

end
