require 'spec_helper'

describe Committee do
  let(:valid_committee) { Committee.make! }

  it "should have unique names" do
    invalid_committee = Committee.create(:name => valid_committee.name)

    valid_committee.should be_valid
    invalid_committee.should_not be_valid
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
    valid_committee.representatives << Representative.make!
    valid_committee.representatives.size.should == 1
  end

  it "won't add the same representative twice" do
    rep = Representative.make!

    valid_committee.representatives << rep
    valid_committee.representatives << rep

    valid_committee.representatives.size.should == 1
  end
end
