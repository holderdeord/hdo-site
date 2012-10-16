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

  it 'is invalid with multiple parties at the same time' do
    rep = Representative.make!

    rep.party_memberships.create(:party => Party.make!, :start_date => 2.months.ago)
    rep.party_memberships.create(:party => Party.make!, :start_date => 1.months.ago)

    rep.should_not be_valid
  end

  it "knows the age" do
    rep = Representative.make!(:date_of_birth => Date.parse("1980-01-01"))
    Date.stub(today: Date.parse("2012-01-01"))

    rep.age.should == 32
  end

  it "can add party memberships" do
    previous_party = Party.make!
    current_party = Party.make!

    rep = Representative.make!

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
    representative.committee_memberships.create! committee: Committee.make!, start_date: 1.month.ago
    representative.committees.size.should == 1
  end

  it 'can fetch the current committees' do
    c1 = Committee.make!
    c2 = Committee.make!
    c3 = Committee.make!

    representative.committee_memberships.create! committee: c1, start_date: 1.month.ago
    representative.committee_memberships.create! committee: c2, start_date: 2.months.ago
    representative.committee_memberships.create! committee: c3, start_date: 3.months.ago, end_date: 1.month.ago

    representative.current_committees.should == [c1, c2]
    representative.committees_at(Date.today).should == [c1, c2]
    representative.committees_at(2.months.ago).should == [c2, c3]
  end

  it "won't add the same committee twice" do
    c     = Committee.make!
    start = 1.month.ago

    representative.committee_memberships.create committee: c, start_date: start
    representative.committee_memberships.create committee: c, start_date: start

    representative.should_not be_valid
  end
end
