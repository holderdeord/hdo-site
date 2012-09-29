require 'spec_helper'

describe Party do
  it 'has a valid blueprint' do
    Party.make!
  end

  it 'is invalid without a name' do
    Party.make(:name => nil).should be_invalid
  end

  it 'is invalid without unique name' do
    party = Party.make!
    Party.make(:name => party.name).should_not be_valid
  end

  it "knows if it is in government" do
    p = Party.make!
    p.governing_periods.make! :start_date => Date.yesterday, :party => p

    p.should be_in_government
  end

  it 'destroys dependent governing periods when emptied' do
    p = Party.make!
    gp = p.governing_periods.make! :start_date => Date.yesterday, :party => p

    p.governing_periods = []

    expect {
      gp.reload
    }.to raise_error(ActiveRecord::RecordNotFound)
  end


  it 'is invalid without an external_id' do
    Party.make(:external_id => nil).should be_invalid
  end

  it 'is invalid without a unique external_id' do
    party = Party.make!
    Party.make(:external_id => party.external_id).should be_invalid
  end

  it 'will not add the same promise twice' do
    party = Party.make!

    promise = Promise.make!(:parties => [party])
    party.promises.count.should == 1

    party.promises << promise
    party.promises.count.should == 1
  end

  it 'destroys dependent promises when no other parties are associated' do
    pending "need to figure this out"

    party = Party.make!
    Promise.make!(:parties => [party])

    Promise.count.should == 1

    party.promises = []
    Promise.count.should == 0
  end

  it 'destroys dependent promises when destroyed and no other parties are associated' do
    pending "need to figure this out"

    party = Party.make!
    Promise.make!(:parties => [party])
    Promise.count.should == 1

    party.destroy
    Promise.count.should == 0
  end

  it 'knows its current representatives' do
    party = Party.make!

    current_rep = Representative.make!(:party_memberships => [])
    current_rep.party_memberships.create!(:party => party, :start_date => 1.month.ago)

    previous_rep = Representative.make!(:party_memberships => [])
    previous_rep.party_memberships.create!(:party => party, :start_date => 2.months.ago, :end_date => 1.month.ago)

    party.current_representatives.should == [current_rep]
    party.representatives_at(Time.now).should == [current_rep]
    party.representatives_at(40.days.ago).should == [previous_rep]
    party.representatives.should == [current_rep, previous_rep]
  end


  it 'partitions parties by government and opposition' do
    a = Party.make!
    b = Party.make!

    a.governing_periods.create!(:start_date => Date.today)

    governing, opposition = Party.governing_groups

    governing.name.should be_kind_of(String)
    governing.parties.should == [a]

    opposition.name.should be_kind_of(String)
    opposition.parties.should == [b]
  end

  it 'has no group title if there are no one in government' do
    a = Party.make!

    groups = Party.governing_groups
    groups.size.should == 1
    groups.first.name.should be_empty
    groups.first.parties.should == [a]
  end
end
