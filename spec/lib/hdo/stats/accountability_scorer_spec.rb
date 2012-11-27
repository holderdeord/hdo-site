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

        issue.accountability.score_for(rep1.current_party).should == 100.0
        issue.accountability.score_for(rep2.current_party).should == 0.0
      end

      it 'prints aggregates to the given io' do
        Issue.make!(status: 'published')

        io = StringIO.new
        AccountabilityScorer.print(io)
        # TODO: check output
      end

    end
  end
end
