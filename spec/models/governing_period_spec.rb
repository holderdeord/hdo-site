require 'spec_helper'

describe GoverningPeriod do
  it "has a valid machinist blueprint" do
    p = GoverningPeriod.make
    p.should be_valid
  end

  it "requires a party association" do
    g = GoverningPeriod.make :start_date => Date.today,
      :end_date => Date.tomorrow,
      :party => nil
    g.should_not be_valid
  end

  it "requires a start_date" do
    g = GoverningPeriod.make :start_date => nil,
      :end_date => Date.today,
      :party => Party.make!
    g.save.should be_false
  end

  it "knows if today is included when it should be" do
    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday,
      :end_date => Date.tomorrow

    g.include?(Date.today).should be_true

    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday

    g.should include(Date.today)
  end

  it "knows that a date that is too early isn't included" do
    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday,
      :end_date => Date.tomorrow

      g.should_not include(Date.today - 1.week)
  end

  it "knows that a date that is too late isn't included" do
    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday,
      :end_date => Date.tomorrow

      g.should_not include(Date.today + 1.week)
  end

  it "requires that the start date is before the end date" do
    g = GoverningPeriod.make :start_date => Date.today,
      :end_date => Date.today,
      :party => Party.make!
    g.should_not be_valid
  end
end
