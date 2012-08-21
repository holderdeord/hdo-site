require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'votes' do

        include_context :persister

        let :non_personal_vote do
          vote_as_hash = StortingImporter::Vote.example.to_hash
          vote_as_hash['personal'] = false
          vote_as_hash.delete 'representatives'
          vote_as_hash['propositions'][0]['deliveredBy'] = nil # less stubbing.

          vote = StortingImporter::Vote.from_hash vote_as_hash
          vote.should be_valid

          vote
        end

        it 'imports multiple votes'
        it 'imports a vote'
        it 'fails if the vote is invalid'
        it 'updates an existing vote based on external_id'

        it 'runs the VoteInferrer after importing votes' do
          ParliamentIssue.make! :external_id => non_personal_vote.external_issue_id

          inferrer = VoteInferrer.new([])

          Hdo::VoteInferrer.should_receive(:new).
                           with([kind_of(Vote)]).
                           and_return(inferrer)

          inferrer.should_receive(:infer!)

          persister.import_votes [non_personal_vote]
        end

        it 'does not try to infer results for the same vote twice' do
          pending "make sure #uniq is called on the result of import"
        end

      end
    end
  end
end
