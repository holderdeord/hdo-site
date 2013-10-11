require 'spec_helper'

module Hdo
  module Stats
    describe AccountabilityScorer do

      it 'does not fail when some promises but no votes are connected' do
        party   = Party.make!
        issue   = Issue.make!(vote_connections: [])

        # [nil, nil].sum will fail with a NoMethodError, so there should be two connections
        # for the same party here
        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for')
        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for')

        score = issue.accountability.score_for(party)
        key = issue.accountability.key_for(party)

        score.should_not be_nil
        score.should be_nan

        key.should == :unknown
      end

      it 'does not consider only related promises as unknown' do
        issue = Issue.make
        vote  = issue.vote_connections[0].vote
        party = vote.vote_results[0].representative.party_at(vote.time)

        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'related')

        score = issue.accountability.score_for(party)
        key = issue.accountability.key_for(party)

        score.should be_nil
        key.should == :no_promises
      end

      it 'generates CSV' do
        Issue.make!(status: 'published')

        AccountabilityScorer.csv.should be_kind_of(String)
        AccountabilityScorer.csv_by_category.should be_kind_of(String)
      end

      it "has a text representation of an entity's score" do
        party  = stub
        scorer = AccountabilityScorer.new(Issue.make)

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(party).and_return 33
          scorer.text_score_for(party).should == '33%'

          scorer.stub(:score_for).with(party).and_return nil
          scorer.text_score_for(party).should == 'Uvisst'
        end
      end

      it 'uses override if present' do
        issue = Issue.make!
        party = Party.make!

        conn = issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for', override: 100)
        AccountabilityScorer.new(issue).score_for(party).should == 100

        conn.update_attributes!(override: 0)
        AccountabilityScorer.new(issue).score_for(party).should == 0
      end

      it 'does not attempt to score valence issues if no overrides are present' do
        issue = Issue.make!
        party = Party.make!

        issue.stub(:stats).and_return stub(score_for: 100)
        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for')

        AccountabilityScorer.new(issue).key_for(party).should == :unknown
      end

    end
  end
end
