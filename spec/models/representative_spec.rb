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

    rep.party_at(Time.current).should == current_party
    rep.party_membership_at(Time.current).should == current_membership

    rep.party_at(40.days.ago).should == previous_party
    rep.party_membership_at(40.days.ago).should == previous_membership
  end

  it "knows the representatives' latest party" do
    rep = Representative.make!
    party = Party.make!

    rep.party_memberships.create!(:party => party, :start_date => 2.months.ago, :end_date => 1.month.ago)

    rep.current_party.should be_nil
    rep.latest_party.should == party
  end

  it 'knows if the representative has an image' do
    representative.stub(image: 'foo/bar/unknown.jpg')
    representative.should_not have_image

    representative.stub(image: 'foo/bar/baz.jpg')
    representative.should have_image
  end

  it 'knows if the representative has a twitter account' do
    representative.stub(twitter_id: nil)
    representative.should_not have_twitter

    representative.stub(twitter_id: '')
    representative.should_not have_twitter

    representative.stub(twitter_id: '    ')
    representative.should_not have_twitter

    representative.stub(twitter_id: 'foo')
    representative.should have_twitter
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

  it 'require a unique twitter_id' do
    Representative.make!(twitter_id: "polit")

    representative.twitter_id = 'polit'
    representative.should_not be_valid
  end

  it 'does not allow @ in twitter_id' do
    rep = Representative.make(twitter_id: '@foo')
    rep.should_not be_valid
  end

  it 'validates format of email' do
    representative.email = 'foo'
    representative.should_not be_valid

    representative.email = 'foo@bar.com'
    representative.should be_valid
  end

  it 'validates uniqueness of email' do
    Representative.make!(email: 'foo@bar.com')

    representative.email = 'foo@bar.com'
    representative.should_not be_valid
  end

  it 'returns the twitter profile url' do
    representative.twitter_id = 'foo'
    representative.twitter_url.should == "https://twitter.com/foo"
  end

  it 'finds attending representatives' do
    a, b = [
      Representative.make!(attending: true),
      Representative.make!(attending: false)
    ]

    Representative.attending.to_a.should == [a]
  end

  it 'finds representatives with email' do
    a, b = [
      Representative.make!(email: 'foo@bar.com'),
      Representative.make!(email: nil),
    ]

    Representative.with_email.to_a.should == [a]
  end

  it 'finds askable representatives' do
    a, b, c, d = [
      Representative.make!(email: 'foo@bar.com', attending: false),
      Representative.make!(email: nil, attending: true),
      Representative.make!(email: 'bah@bar.com', attending: true),
      Representative.make!(:confirmed,  { attending: true, opted_out: true })
    ]

    a.should_not be_askable
    b.should_not be_askable
    c.should be_askable
    d.should_not be_askable

    Representative.askable.should eq [c]
    Representative.potentially_askable.should eq [c,d]
    Representative.opted_out.should eq [d]
  end
end
