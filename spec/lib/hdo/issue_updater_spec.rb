require 'spec_helper'

module Hdo
  describe IssueUpdater do
    let(:user) { User.make! }

    describe 'valence issue explanations' do
      let(:issue) { Issue.make! }

      it 'adds explanations' do
        party = Party.make!

        explanations = {
          'new1' => {
            'id'          => '1',
            'parties'     => [party.id],
            'title'       => 'foo',
            'explanation' => 'Offer one gazillion!',
            'issue_id'    => issue.id
          }
        }

        expect {
          IssueUpdater.new(issue, {valence_issue_explanations: explanations}, user).update!
        }.to change(issue.valence_issue_explanations, :count).by(1)
      end

      it 'modifies explanations' do
        e = ValenceIssueExplanation.make! issue: issue

        explanations = {
          e.id => {
            'id'          => e.id,
            'explanation' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties
          }
        }

        IssueUpdater.new(issue, { valence_issue_explanations: explanations }, user).update!
        issue.reload.valence_issue_explanations.first.explanation.should eq 'foo'
      end

      it 'modifies title' do
        e = ValenceIssueExplanation.make! issue: issue

        explanations = {
          e.id => {
            'id'          => e.id,
            'explanation' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties,
            'title'       => 'hello lalala'
          }
        }

        IssueUpdater.new(issue, { valence_issue_explanations: explanations }, user).update!
        issue.reload.valence_issue_explanations.first.title.should eq 'hello lalala'
      end

      it 'modifies priority' do
        e = ValenceIssueExplanation.make! issue: issue

        explanations = {
          e.id => {
            'id'          => e.id,
            'explanation' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties,
            'title'       => 'hello lalala',
            'priority'    => 100
          }
        }

        IssueUpdater.new(issue, { valence_issue_explanations: explanations }, user).update!
        issue.reload.valence_issue_explanations.first.priority.should eq 100
      end

      it 'deletes explanations' do
        e = ValenceIssueExplanation.make! issue: issue

        explanations = {
          e.id => {
            'deleted' => 'true'
          }
        }

        expect {
          IssueUpdater.new(issue, { valence_issue_explanations: explanations }, user).update!
        }.to change(issue.valence_issue_explanations, :count).by(-1)
      end
    end

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

        expected_type = VoteConnection::PROPOSITION_TYPES.first

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: expected_type
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

        issue.vote_connections.map(&:proposition_type).compact.should == [expected_type]
      end

      it "updates multiple proposition_types simultaneously" do
        issue = Issue.make! vote_connections: [VoteConnection.make!, VoteConnection.make!]
        issue.vote_connections.each { |v| v.proposition_type.should be_blank }

        first = VoteConnection::PROPOSITION_TYPES.first
        last  = VoteConnection::PROPOSITION_TYPES.last

        votes = {
          issue.votes[0].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: first
          },
          issue.votes[1].id => {
            direction: 'for',
            weight: 1.0,
            title: 'title!!!!!!!!',
            proposition_type: last
          }
        }

        IssueUpdater.new(issue, {votes: votes}, user).update!
        issue.reload

        actual = issue.vote_connections.map(&:proposition_type).sort
        actual.should == [first, last].sort
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

    describe 'tags' do
      let(:issue) { Issue.make! }

      it 'does not update the issue if tag list did not change' do
        issue.tag_list = 'tannlege, helse og sosial'
        issue.save!
        issue.last_updated_by.should be_nil

        IssueUpdater.new(issue, {issue: {tag_list: 'tannlege,helse og sosial'}}, user).update!
        issue.reload.last_updated_by.should be_nil
      end
    end

    describe 'authorization' do
      let(:issue) { Issue.make! status: 'in_progress' }
      let(:admin) { User.make! role: 'admin' }
      let(:superadmin) { User.make! role: 'superadmin' }

      it "can not publish if authorized as admin" do
        updater = IssueUpdater.new(issue, {issue: {status: 'published'}}, admin)
        expect {
          updater.update!
        }.to raise_error(IssueUpdater::Unauthorized)

        updater.update.should be_false
        issue.errors.should_not be_empty
      end

      it "can publish if authorized as superadmin" do
        updater = IssueUpdater.new(issue, {issue: {status: 'published'}}, superadmin)
        updater.update.should be_true
        issue.errors.should be_empty
      end

      it "can change other statuses if authorized as admin" do
        updater = IssueUpdater.new(issue, {issue: {status: 'in_review'}}, admin)

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