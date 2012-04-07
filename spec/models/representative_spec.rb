require 'spec_helper'

describe Representative do

  it "shows the display name" do
    rep = Representative.create(:first_name => "Donald", :last_name => "Duck")
    rep.display_name.should == "Duck, Donald"
  end

  it "can be created with a party associtaion" do
    party = Party.create(:name => "Democratic Party")
    rep = Representative.create(:first_name => "Donald", :last_name => "Duck", :party => party)

    rep.party.should == party
  end
end
