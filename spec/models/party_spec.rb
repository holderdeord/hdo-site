require 'spec_helper'

describe Party do
  it "returns its percentage of the parliament" do
    Representative.stub!(:count => 100)

    party = Party.create(:name => "Democratic Party")
    Representative.make!(:party => party)

    party.percent_of_representatives.should == 1
  end
end
