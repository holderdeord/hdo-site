require 'spec_helper'

describe Representative do
  it "shows the display name" do
    rep = Representative.make!(:first_name => "Donald", :last_name => "Duck")
    rep.display_name.should == "Duck, Donald"
  end

  it "can be created with a party associtaion" do
    party = Party.make!
    rep = Representative.make!(:first_name => "Donald", :last_name => "Duck", :party => party)

    rep.party.should == party
  end

  it "should have stats" do
    rep = Representative.make!
    rep.stats.should be_kind_of(Hdo::Stats::RepresentativeCounts)
  end

  it 'is invalid without an external_id' do
    Representative.make(:external_id => nil).should_not be_valid
  end

  it 'is invalid without a unique external_id' do
    r = Representative.make!
    Representative.make(:external_id => r.external_id).should_not be_valid
  end
end
