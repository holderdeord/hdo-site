require 'spec_helper'

describe PartyMembership do
  let(:representative) { Representative.make!(:party_memberships => [])}
  let(:party) { Party.make! }

  it 'finds current memberships' do
    representative.party_memberships.make!(:start_date => 60.days.ago, :end_date => 31.days.ago)
    representative.party_memberships.make!(:start_date => 30.days.ago, :end_date => nil)

    PartyMembership.current.size.should == 1
  end

  it 'finds memberships for the given date' do
    membership = representative.party_memberships.make!(:start_date => 1.month.ago, :end_date => 20.days.ago)

    PartyMembership.for_date(25.days.ago).should == [membership]
  end

  it 'knows if itself is current' do
    pms = PartyMembership.make(:start_date => 1.month.ago, :end_date => nil)
    pms.should be_current

    pms = PartyMembership.make(:start_date => 1.month.ago, :end_date => 1.month.from_now)
    pms.should be_current

    pms = PartyMembership.make(:start_date => 1.month.ago, :end_date => 10.days.ago)
    pms.should_not be_current
  end

  it 'can not overlap in time for the same representative (open ended)' do
    valid = representative.party_memberships.make!(:start_date => 1.month.ago, :end_date => nil, :party => Party.make!)
    invalid = representative.party_memberships.make(:start_date => 20.days.ago, :end_date => nil, :party => Party.make!)

    invalid.should_not be_valid
  end

  it 'is invalid if end date comes before start date' do
    pms = PartyMembership.make(:start_date => 1.day.ago, :end_date => 1.month.ago)
    pms.should_not be_valid
  end

  it 'knows if two memberships overlap' do
    a = PartyMembership.make(:start_date => Date.new(2009, 1, 1), :end_date => Date.new(2011, 1, 1))
    b = PartyMembership.make(:start_date => Date.new(2010, 1, 1), :end_date => Date.new(2012, 1, 1))
    c = PartyMembership.make(:start_date => Date.new(2011, 6, 1), :end_date => nil)

    a.intersects?(b).should be_true
    b.intersects?(a).should be_true

    b.intersects?(c).should be_true
    c.intersects?(b).should be_true

    a.intersects?(c).should be_false
    c.intersects?(a).should be_false
  end

  it 'knows if it is open ended' do
    PartyMembership.make(:end_date => nil).should be_open_ended
    PartyMembership.make(:end_date => Date.today).should_not be_open_ended
  end
end
