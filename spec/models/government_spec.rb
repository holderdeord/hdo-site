require 'spec_helper'
require 'models/shared/open_ended_date_range'

describe Government do
  it_behaves_like Hdo::Model::OpenEndedDateRange

  it "has a valid blueprint" do
    Government.make.should be_valid
  end

  it "requires a name" do
    Government.make(name: nil).should_not be_valid
  end

  xit "requires a party association" do
    Government.make(start_date: Date.today, end_date: Date.tomorrow).should_not be_valid
  end

  it 'is invalid without a start date' do
    Government.make(start_date: nil).should_not be_valid
  end

  it 'does not allow multiple overlapping governments' do
    Government.make!(start_date: 4.years.ago, end_date: 1.month.ago)

    Government.make(start_date: 3.years.ago, end_date: nil).should_not be_valid
    Government.make(start_date: 5.years.ago, end_date: nil).should_not be_valid
    Government.make(start_date: 5.years.ago, end_date: 3.months.ago).should_not be_valid
    Government.make(start_date: 5.years.ago, end_date: Date.today).should_not be_valid
  end

  it 'has a unique name' do
    Government.make!(name: 'foo')
    Government.make(name: 'foo').should_not be_valid
  end

  it "knows if today is included when it should be" do
    g = Government.make(
      start_date: Date.yesterday,
      end_date: Date.tomorrow
    )

    g.include?(Date.today).should be_true

    g = Government.make(
      start_date: Date.yesterday
    )

    g.should include(Date.today)
  end

  it "knows that a date that is too early isn't included" do
    g = Government.make(
      start_date: Date.yesterday,
      end_date: Date.tomorrow
    )

    g.should_not include(Date.today - 1.week)
  end

  it "knows that a date that is too late isn't included" do
    g = Government.make(
      start_date: Date.yesterday,
      end_date: Date.tomorrow
    )

    g.should_not include(Date.today + 1.week)
  end

  it "requires that the start date is before the end date" do
    g = Government.make(
      start_date: Date.today + 1,
      end_date: Date.today,
    )

    g.should_not be_valid
  end
end
