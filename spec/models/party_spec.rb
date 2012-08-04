require 'spec_helper'

describe Party do
  it "returns its percentage of the parliament" do
    Representative.stub!(:count => 100)

    party = Party.make!(:name => "Democratic Party")
    Representative.make!(:party => party)

    party.percent_of_representatives.should == 1
  end

  it 'is invalid without a name' do
    Party.make(:name => nil).should_not be_valid
  end

  it 'is invalid without unique name' do
    party = Party.make!
    Party.make(:name => party.name).should_not be_valid
  end
end
