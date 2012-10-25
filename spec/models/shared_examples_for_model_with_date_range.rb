require 'spec_helper'

shared_examples 'model with date range' do
  it "requires a start_date" do
    described_class.make(:full, :start_date => nil).should_not be_valid
  end

  it 'knows if itself is current' do
    obj = described_class.new(:start_date => 1.month.ago, :end_date => nil)
    obj.should be_current

    obj = described_class.new(:start_date => 1.month.ago, :end_date => 1.month.from_now)
    obj.should be_current

    obj = described_class.new(:start_date => 1.month.ago, :end_date => 10.days.ago)
    obj.should_not be_current
  end

  it 'knows if two memberships intersects' do
    a = described_class.new(:start_date => Date.new(2009, 1, 1), :end_date => Date.new(2011, 1, 1))
    b = described_class.new(:start_date => Date.new(2010, 1, 1), :end_date => Date.new(2012, 1, 1))
    c = described_class.new(:start_date => Date.new(2011, 6, 1), :end_date => nil)

    a.intersects?(b).should be_true
    b.intersects?(a).should be_true

    b.intersects?(c).should be_true
    c.intersects?(b).should be_true

    a.intersects?(c).should be_false
    c.intersects?(a).should be_false
  end

  it 'knows if it is open ended' do
    described_class.new(:end_date => nil).should be_open_ended
    described_class.new(:end_date => Date.today).should_not be_open_ended
  end

  it 'finds current memberships' do
    described_class.make!(:full, :start_date => 60.days.ago, :end_date => 31.days.ago)
    described_class.make!(:full, :start_date => 30.days.ago, :end_date => nil)

    described_class.current.size.should == 1
  end

  it 'finds memberships for the given date' do
    membership = described_class.make!(:full, :start_date => 1.month.ago, :end_date => 20.days.ago)

    described_class.for_date(25.days.ago).should == [membership]
  end

  it 'is invalid if end date comes before start date' do
    obj = described_class.new(:start_date => 1.day.ago, :end_date => 1.month.ago)
    obj.should_not be_valid
  end
end