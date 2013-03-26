require 'spec_helper'

module Hdo
  describe IssueUpdater do
    let(:user) { User.make! }

    describe 'party comments' do
      let(:issue) { Issue.make! }
      let(:party) { Party.make! }

      it "adds party comments" do
        party_comments = {
          "new1" => {
            "id"       => "1",
            "issue_id" => issue.id,
            "party_id" => party.id,
            "body"     => "we disagree with the analysis!"
          }
        }

        expect {
          IssueUpdater.new(issue, {party_comments: party_comments }, user).update!
          issue.reload
        }.to change(issue.party_comments, :count).by(1)
      end

      it "modifies party comments" do
        party_comment = PartyComment.make! party: party, issue: issue, body: "Spot on!"

        party_comments = {
          party_comment.id => {
            "id"       => party_comment.id,
            "issue_id" => issue.id,
            "party_id" => party.id,
            "body"     => "we disagree with the analysis!"
          }
        }

        IssueUpdater.new(issue, { party_comments: party_comments }, user).update!
        issue.reload
        issue.party_comments.first.body.should == "we disagree with the analysis!"
      end

      it "deletes party comments" do
        party_comment = PartyComment.make! party: party, issue: issue

        party_comments = {
          party_comment.id => {
            "deleted" => "true"
          }
        }

        expect {
          IssueUpdater.new(issue, { party_comments: party_comments }, user).update!
          issue.reload
        }.to change(issue.party_comments, :count).by(-1)
      end
    end

    describe 'vote proposition types' do
      it "updates a single proposition_type" do
        issue = Issue.make! vote_connections: [VoteConnection.make!]

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: VoteConnection::PROPOSITION_TYPES.first
          }
        }

        IssueUpdater.new(issue, {votes: votes}, user).update!

        issue.reload

        issue.vote_connections.each do |vc|
          vc.proposition_type.should == VoteConnection::PROPOSITION_TYPES.first
        end
      end

      it "updates one of many proposition_types" do
        issue = Issue.make! vote_connections: [VoteConnection.make!, VoteConnection.make!]
        issue.vote_connections.each { |v| v.proposition_type.should be_blank }

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: VoteConnection::PROPOSITION_TYPES.first
          },
          issue.votes[1].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: ""
          }
        }

        IssueUpdater.new(issue, {votes: votes}, user).update!
        issue.reload

        issue.vote_connections.first.proposition_type.should == VoteConnection::PROPOSITION_TYPES.first
      end

      it "updates multiple proposition_types simultaneously" do
        issue = Issue.make! vote_connections: [VoteConnection.make!, VoteConnection.make!]
        issue.vote_connections.each { |v| v.proposition_type.should be_blank }

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: VoteConnection::PROPOSITION_TYPES.first
          },
          issue.votes[1].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: VoteConnection::PROPOSITION_TYPES.last
          }
        }

        IssueUpdater.new(issue, {votes: votes}, user).update!
        issue.reload

        issue.vote_connections[0].proposition_type.should == VoteConnection::PROPOSITION_TYPES.first
        issue.vote_connections[1].proposition_type.should == VoteConnection::PROPOSITION_TYPES.last
      end

      it 'does not touch the issue if proposition type is already nil or empty' do
        vote_connection = VoteConnection.make!(matches: true)
        vote            = vote_connection.vote
        issue           = Issue.make! vote_connections: [vote_connection]

        vote_connection.proposition_type.should be_nil
        issue.last_updated_by.should be_nil

        votes = {
          vote.id => {
            direction: 'for',
            weight: vote_connection.weight,
            title: vote_connection.title,
            proposition_type: '' # input is an empty string
          }
        }

        IssueUpdater.new(issue, {votes: votes}, user).update!
        issue.last_updated_by.should be_nil
      end
    end

    describe 'authorization' do
      let(:issue) { Issue.make! status: 'in_progress' }
      let(:admin) { User.make! role: 'admin' }
      let(:superadmin) { User.make! role: 'superadmin' }

      it "can not change status if authorized as admin" do
        updater = IssueUpdater.new(issue, {issue: {status: 'published'}}, admin)
        expect {
          updater.update!
        }.to raise_error(IssueUpdater::Unauthorized)

        updater.update.should be_false
        issue.errors.should_not be_empty
      end

      it "can change status if authorized as superadmin" do
        updater = IssueUpdater.new(issue, {issue: {status: 'published'}}, superadmin)
        updater.update.should be_true
        issue.errors.should be_empty
      end

      it 'sets published_at if the issue is being published' do
        issue.should_receive(:published_at=).with(instance_of(Time))

        updater = IssueUpdater.new(issue, {issue: {status: 'published'}}, superadmin)
        updater.update.should be_true
      end

      it 'sets does not set published_at on any status change' do
        issue = Issue.make! status: 'published'
        issue.should_receive(:published_at=).never

        updater = IssueUpdater.new(issue, {issue: {status: 'in_progress'}}, superadmin)
        updater.update.should be_true
      end

      it 'can not perform updates if the user has a non-admin role' do
        updater = IssueUpdater.new(issue, {issue: {title: 'foo'}}, User.make!(role: 'contributor'))

        expect {
          updater.update!
        }.to raise_error(IssueUpdater::Unauthorized)
      end
    end
  end
end