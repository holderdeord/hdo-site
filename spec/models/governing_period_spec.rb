require 'spec_helper'

describe GoverningPeriod do
  it "has a valid machinist blueprint" do
    GoverningPeriod.make.save.should_not be_nil
  end

  it "requires a party association" do
    g = GoverningPeriod.make :start_date => Date.today,
      :end_date => Date.today,
      :party => nil
    g.save.should be_false
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

    g.include?(Date.today).should be_true
  end

  it "knows that a date that is too early isn't included" do
    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday,
      :end_date => Date.tomorrow

      g.include?(Date.today - 1.week).should be_false
  end

  it "knows that a date that is too late isn't included" do
    g = GoverningPeriod.make :party => Party.make!,
      :start_date => Date.yesterday,
      :end_date => Date.tomorrow

      g.include?(Date.today + 1.week).should be_false
  end
end
