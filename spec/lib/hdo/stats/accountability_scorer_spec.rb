require 'spec_helper'

module Hdo
  module Stats
    describe AccountabilityScorer do

      it 'calculates party score based on votes and promises' do
        rep = Representative.make!(:full)

        vote    = Vote.make!(vote_results: [VoteResult.make!(representative: rep, :result => 1)])
        promise = Promise.make!(parties: [rep.current_party])

        issue = Issue.make!(vote_connections: [])
        issue.vote_connections.create!(vote: vote, weight: 1.0, matches: true)
        issue.promise_connections.create!(promise: promise, status: "for")

        issue.accountability.score_for(rep.current_party).should == 100.0
      end

    end
  end
end
