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


  describe IssueDecorator::PartyVote do
    let(:party) { stub(Party) }
    let(:vote_connection) { stub(:vote_connection) }
    let(:party_vote) { IssueDecorator::PartyVote.new party, vote_connection }

    it 'ignores vote connections where the party rejects an alternate budget' do
      vote_connection.as_null_object
      vote_connection.stub(proposition_type: 'alternate_national_budget')
      vote_connection.vote.stats.stub(:party_for? => false)

      party_vote.should be_ignored
    end
  end
end