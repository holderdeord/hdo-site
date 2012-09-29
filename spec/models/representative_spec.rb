require 'spec_helper'

describe Representative do
  let(:representative) { Representative.make! }

  it 'has a valid bluprint' do
    representative.should be_valid
  end

  it "shows the display name" do
    rep = Representative.make!(:first_name => "Donald", :last_name => "Duck")
    rep.display_name.should == "Duck, Donald"
  end

  it "can add party associations" do
    previous_party = Party.make!
    current_party = Party.make!

    rep = Representative.make!(:party_memberships => [])

    previous_membership = rep.party_memberships.create!(:party => previous_party, :start_date => 2.months.ago, :end_date => 1.month.ago)
    current_membership  = rep.party_memberships.create!(:party => current_party, :start_date => 29.days.ago)

    rep.current_party.should == current_party
    rep.current_party_membership.should == current_membership

    rep.party_at(Time.now).should == current_party
    rep.party_membership_at(Time.now).should == current_membership

    rep.party_at(40.days.ago).should == previous_party
    rep.party_membership_at(40.days.ago).should == previous_membership
  end

  it "should have stats" do
    representative.stats.should be_kind_of(Hdo::Stats::RepresentativeCounts)
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

  it 'can add committees' do
    representative.committees << Committee.make!
    representative.committees.size.should == 1
  end

  it "won't add the same committee twice" do
    c = Committee.make!

    representative.committees << c
    representative.committees << c

    representative.committees.size.should == 1
  end

  it 'is invalid with multiple parties at the same time' do
    rep = Representative.make!(:party_memberships => [])

    rep.party_memberships.create(:party => Party.make!, :start_date => 2.months.ago)
    rep.party_memberships.create(:party => Party.make!, :start_date => 1.months.ago)

    rep.should_not be_valid
  end
end
