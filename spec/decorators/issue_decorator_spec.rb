require 'spec_helper'

describe IssueDecorator do
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