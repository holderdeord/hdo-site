require 'spec_helper'

module Hdo
  module Stats
    describe AccountabilityScorer do

      it 'calculates party score based on votes and promises' do
        rep1 = Representative.make!(:full)
        rep2 = Representative.make!(:full)

        vote = Vote.make!(vote_results: [
          VoteResult.make!(representative: rep1, :result => 1),
          VoteResult.make!(representative: rep2, :result => 1)
        ])

        promise1 = Promise.make!(parties: [rep1.current_party])
        promise2 = Promise.make!(parties: [rep2.current_party])

        issue = Issue.make!(vote_connections: [])
        issue.vote_connections.create!(vote: vote, weight: 1.0, matches: true)
        issue.promise_connections.create!(promise: promise1, status: "for")
        issue.promise_connections.create!(promise: promise2, status: "against")

        accountability = issue.accountability

        accountability.score_for(rep1.current_party).should == 100.0
        accountability.score_for(rep2.current_party).should == 0.0

        I18n.with_locale(:nb) do
          accountability.text_for(rep1.current_party).should == "De har <strong>holdt ord</strong> i denne saken."
          accountability.text_for(rep2.current_party).should == "De har <strong>ikke holdt ord</strong> i denne saken."
        end
      end

      it 'does not fail when some promises but no votes are connected' do
        party   = Party.make!
        issue   = Issue.make!(vote_connections: [])

        # [nil, nil].sum will fail with a NoMethodError, so there should be two connections
        # for the same party here
        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for')
        issue.promise_connections.create!(promise: Promise.make!(parties: [party]), status: 'for')

        issue.accountability.score_for(party).should be_nil
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

    end
  end
end
