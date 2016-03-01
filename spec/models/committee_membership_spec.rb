require 'spec_helper'
require 'models/shared/open_ended_date_range'

describe CommitteeMembership do
  it_behaves_like Hdo::Model::OpenEndedDateRange

  it 'is invalid with overlapping memberships in the same committee' do
    c = Committee.make!
    r = Representative.make!

    CommitteeMembership.create!(
      representative: r,
      committee: c,
      start_date: 1.month.ago
    )

    # overlapping in different committe
    CommitteeMembership.create!(
      representative: r,
      committee: Committee.make!,
      start_date: 10.days.ago
    )

    # overlapping in same committe
    CommitteeMembership.create(
      representative: r,
      committee: c,
      start_date: 10.days.ago
    ).should_not be_valid
  end

  it 'knows if two memberships intersects' do
    a = CommitteeMembership.make(:start_date => Date.new(2009, 1, 1), :end_date => Date.new(2011, 1, 1))
    b = CommitteeMembership.make(:start_date => Date.new(2010, 1, 1), :end_date => Date.new(2012, 1, 1))
    c = CommitteeMembership.make(:start_date => Date.new(2011, 6, 1), :end_date => nil)

    a.intersects?(b).should be true
    b.intersects?(a).should be true

    b.intersects?(c).should be true
    c.intersects?(b).should be true

    a.intersects?(c).should be false
    c.intersects?(a).should be false
  end

end
