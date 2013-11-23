require 'spec_helper'

describe IssueDecorator do
  describe IssueDecorator::PartyVote do
    let(:party) { stub(Party) }
    let(:proposition_connection) { stub(:proposition_connection) }
    let(:party_vote) { IssueDecorator::PartyVote.new party, proposition_connection }

    it 'ignores proposition connections where the party rejects an alternate budget' do
      proposition_connection.as_null_object
      proposition_connection.stub(proposition_type: 'alternate_national_budget')
      proposition_connection.vote.stats.stub(:party_for? => false)

      party_vote.should be_ignored
    end
  end
end