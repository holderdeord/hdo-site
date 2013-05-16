require 'spec_helper'
require 'models/shared_examples_for_model_with_date_range'

describe CommitteeMembership do
  it_behaves_like 'model with date range'

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

    a.intersects?(b).should be_true
    b.intersects?(a).should be_true

    b.intersects?(c).should be_true
    c.intersects?(b).should be_true

    a.intersects?(c).should be_false
    c.intersects?(a).should be_false
  end

end
