require 'spec_helper'

module Hdo
  module Stats
    describe AccountabilityScorer do

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

      it 'calculates score based on override' do
        issue = Issue.make!
        party = Party.make!

        conn = issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for', override: 100)
        AccountabilityScorer.new(issue).score_for(party).should == 100

        conn.update_attributes!(override: 0)
        AccountabilityScorer.new(issue).score_for(party).should == 0
      end

    end
  end
end
