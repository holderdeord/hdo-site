require 'spec_helper'

describe Party do
  it 'has a valid blueprint' do
    Party.make!
  end

  it "returns its percentage of the parliament" do
    Representative.stub!(:count => 100)

    party = Party.make!(:name => "Democratic Party")
    Representative.make!(:party => party)

    party.percent_of_representatives.should == 1
  end

  it 'is invalid without a name' do
    Party.make(:name => nil).should be_invalid
  end

  it 'is invalid without unique name' do
    party = Party.make!
    Party.make(:name => party.name).should_not be_valid
  end

  it "knows if it is in the government coalition" do
    p = Party.make!
    p.governing_periods << (GoverningPeriod.make! :start_date => Date.yesterday,
      :party => p)

    p.in_gov?.should be_true
  end

  it 'is invalid without an external_id' do
    Party.make(:external_id => nil).should be_invalid
  end

  it 'is invalid without a unique external_id' do
    party = Party.make!
    Party.make(:external_id => party.external_id).should be_invalid
  end
end
