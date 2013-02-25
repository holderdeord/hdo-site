require 'spec_helper'

describe IssueDecorator do
  it 'partitions parties by government and opposition' do
    a = Party.make!
    b = Party.make!

    a.governing_periods.create!(start_date: Date.today)

    governing, opposition = Issue.new.decorate.party_groups

    governing.name.should be_kind_of(String)
    governing.parties.should == [a]

    opposition.name.should be_kind_of(String)
    opposition.parties.should == [b]
  end

  it 'has no group title if there are no one in government' do
    a = Party.make!

    groups = Issue.new.decorate.party_groups
    groups.size.should == 1
    groups.first.name.should be_empty
    groups.first.parties.map(&:external_id).should == [a.external_id]
  end

end