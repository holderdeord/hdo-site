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
end
