require 'spec_helper'

describe Committee do
  let(:valid_committee) { Committee.make! }

  it "has a unique of names" do
    invalid_committee = Committee.create(:name => valid_committee.name)

    valid_committee.should be_valid
    invalid_committee.should_not be_valid
  end

  it "has a unique external id" do
    invalid = Committee.make!
    invalid.external_id = valid_committee.external_id

    invalid.should_not be_valid
  end

  it "can add parliament issues" do
    a = ParliamentIssue.make! last_update: 2.hours.ago
    b = ParliamentIssue.make! last_update: 1.hour.ago

    c = valid_committee

    c.parliament_issues << a
    c.parliament_issues << b

    c.parliament_issues.map(&:description).should == [a.description, b.description]
    c.should be_valid
  end

  it 'can add representatives' do
    rep   = Representative.make!
    start = 1.month.ago

    valid_committee.committee_memberships.create(representative: rep, start_date: start)
    valid_committee.representatives.size.should == 1
  end

  it "won't add the same representative twice" do
    com   = valid_committee
    rep   = Representative.make!
    start = 1.month.ago

    com.committee_memberships.create(representative: rep, start_date: start)
    com.committee_memberships.create(representative: rep, start_date: start)

    com.should_not be_valid
  end

  it 'knows its current memberships' do
    rep1 = Representative.make!
    rep2 = Representative.make!
    com = valid_committee

    com.committee_memberships.create!(representative: rep1, start_date: 1.month.ago)
    com.committee_memberships.create!(representative: rep2, start_date: 1.month.ago, end_date: 3.days.ago)

    com.current_representatives.should == [rep1]
    com.representatives_at(5.days.ago).should == [rep1, rep2]
  end

  it 'destroys dependent memeberships when destroyed' do
    com = Committee.make!
    rep = Representative.make!

    com.committee_memberships.create!(representative: rep, start_date: 1.month.ago)
    rep.committee_memberships.size.should == 1

    com.destroy

    rep.party_memberships.should == []
  end
end
