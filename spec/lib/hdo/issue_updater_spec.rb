require 'spec_helper'

module Hdo
  describe IssueUpdater do
    let(:user) { User.make! }

    describe 'vote proposition types' do
      it "updates a single vote's proposition_type" do
        issue = Issue.make! vote_connections: [VoteConnection.make!]

        issue.votes.each { |v| v.proposition_type.should be_blank }

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: Vote::PROPOSITION_TYPES.first
          }
        }

        IssueUpdater.new(issue, {}, votes, user).update!

        issue.reload

        issue.votes.each do |vote|
          vote.proposition_type.should == Vote::PROPOSITION_TYPES.first
        end
      end

      it "updates one of many vote's proposition_type" do
        issue = Issue.make! vote_connections: [VoteConnection.make!, VoteConnection.make!]
        issue.votes.each { |v| v.proposition_type.should be_blank }

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: Vote::PROPOSITION_TYPES.first
          },
          issue.votes[1].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: ""
          }
        }

        IssueUpdater.new(issue, {}, votes, user).update!
        issue.reload

        issue.votes[0].proposition_type.should == Vote::PROPOSITION_TYPES.first
      end

      it "updates multiple vote's proposition_type simultaneously" do
        issue = Issue.make! vote_connections: [VoteConnection.make!, VoteConnection.make!]
        issue.votes.each { |v| v.proposition_type.should be_blank }

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: Vote::PROPOSITION_TYPES.first
          },
          issue.votes[1].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: Vote::PROPOSITION_TYPES.last
          }
        }

        IssueUpdater.new(issue, {}, votes, user).update!
        issue.reload

        issue.votes[0].proposition_type.should == Vote::PROPOSITION_TYPES.first
        issue.votes[1].proposition_type.should == Vote::PROPOSITION_TYPES.last
      end
    end
  end
end