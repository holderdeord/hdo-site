require 'spec_helper'

module Hdo
  describe IssueUpdater do
    let(:user) { User.make! }

    describe 'positions' do
      let(:issue) { Issue.make! }

      it 'adds positions' do
        party = Party.make!

        positions = {
          'new1' => {
            'id'                   => '1',
            'parties'              => [party.id],
            'title'                => 'foo',
            'description'          => 'Offer one gazillion!',
            'issue_id'             => issue.id,
          }
        }

        expect {
          IssueUpdater.new(issue, {positions: positions}, user).update!
        }.to change(issue.positions, :count).by(1)
      end

      it 'modifies positions' do
        e = Position.make! issue: issue

        positions = {
          e.id => {
            'id'          => e.id,
            'description' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties
          }
        }

        IssueUpdater.new(issue, { positions: positions }, user).update!
        issue.reload.positions.first.description.should eq 'foo'
      end

      it 'modifies title' do
        e = Position.make! issue: issue

        positions = {
          e.id => {
            'id'          => e.id,
            'description' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties,
            'title'       => 'hello lalala'
          }
        }

        IssueUpdater.new(issue, { positions: positions }, user).update!
        issue.reload.positions.first.title.should eq 'hello lalala'
      end

      it 'modifies priority' do
        e = Position.make! issue: issue

        positions = {
          e.id => {
            'id'          => e.id,
            'description' => 'foo',
            'issue_id'    => e.issue_id,
            'parties'     => e.parties,
            'title'       => 'hello lalala',
            'priority'    => 100
          }
        }

        IssueUpdater.new(issue, { positions: positions }, user).update!
        issue.reload.positions.first.priority.should eq 100
      end

      it 'modifies parliament period' do
        p = ParliamentPeriod.make!
        e = Position.make! issue: issue

        positions = {
          e.id => {
            'id'                   => e.id,
            'description'          => 'foo',
            'issue_id'             => e.issue_id,
            'parties'              => e.parties,
            'title'                => 'hello lalala',
            'priority'             => 100,
            'parliament_period_id' => p.id
          }
        }

        IssueUpdater.new(issue, { positions: positions }, user).update!
        issue.reload.positions.first.parliament_period.should == p
      end

      it 'deletes positions' do
        e = Position.make! issue: issue

        positions = {
          e.id => {
            'deleted' => 'true'
          }
        }

        expect {
          IssueUpdater.new(issue, { positions: positions }, user).update!
        }.to change(issue.positions, :count).by(-1)
      end
    end

    describe 'party comments' do
      let(:issue) { Issue.make! }
      let(:party) { Party.make! }
      let(:parliament_period) { ParliamentPeriod.make! }

      it "adds party comments" do
        party_comments = {
          "new1" => {
            "id"                   => "1",
            "issue_id"             => issue.id,
            "party_id"             => party.id,
            "parliament_period_id" => parliament_period.id,
            "body"                 => "we disagree with the analysis!"
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

    describe 'promise connections' do
      let(:issue) { Issue.make! }
      before { ParliamentPeriod.stub(current: double(start_date: 1.month.ago.to_date))}

      it 'adds promise connections' do
        promise = Promise.make!

        promises = {
          promise.id => {'status' => 'related'}
        }.with_indifferent_access

        expect {
          IssueUpdater.new(issue, { promises: promises}, user).update!
          issue.reload
        }.to change(issue.promise_connections, :count).by(1)
      end

      it 'modifies a promise connection' do
        promise = Promise.make!
        PromiseConnection.make! promise: promise, issue: issue

        promises = {
          promise.id => {'status' => 'kept'}
        }.with_indifferent_access

        IssueUpdater.new(issue, {promises: promises }, user).update!
        issue.reload.promise_connections.first.should be_kept
      end

      it 'deletes promise connections' do
        promise = Promise.make!
        PromiseConnection.make! promise: promise, issue: issue

        promises = {
          promise.id => {'status' => 'unrelated'}
        }.with_indifferent_access

        expect {
          IssueUpdater.new(issue, { promises: promises }, user).update!
          issue.reload
        }.to change(issue.promise_connections, :count).by(-1)
      end
    end

    describe 'proposition connections' do
      it 'keeps title and comment nil if blank' do
        conn  = PropositionConnection.make!(title: nil, comment: nil)
        issue = Issue.make! proposition_connections: [conn]

        propositions = {
          conn.proposition.id => [{
            connected: 'true',
            title: '',
            comment: ''
          }]
        }

        IssueUpdater.new(issue, {propositions: propositions}, user).update!

        conn.reload
        conn.title.should be_nil
        conn.comment.should be_nil
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
