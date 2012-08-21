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

  it 'removes vote results if the representative is destroyed' do
    v = Vote.make!
    r = v.vote_results.first.representative

    expect { r.destroy }.to change(VoteResult, :count).from(1).to(0)
  end
end
