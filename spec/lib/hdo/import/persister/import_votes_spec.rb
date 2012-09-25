require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'votes' do

        include_context :persister

        def setup_vote(vote)
          vote.representatives.each do |rep|
            rep.committees.each { |n| Committee.make!(:name => n) }
            District.make!(:name => rep.district)
            Party.make!(:name => rep.party)
          end

          ParliamentIssue.make!(:external_id => vote.external_issue_id)
        end

        let :non_personal_vote do
          vote_as_hash = StortingImporter::Vote.example.to_hash
          vote_as_hash['personal'] = false
          vote_as_hash.delete 'representatives'
          vote_as_hash['propositions'][0]['deliveredBy'] = nil # less stubbing.

          vote = StortingImporter::Vote.from_hash vote_as_hash
          vote.should be_valid

          vote
        end

        it 'imports a vote' do
          vote = StortingImporter::Vote.example
          setup_vote(vote)

          persister.import_vote vote

          Vote.count.should == 1
        end

        it 'runs the VoteInferrer after importing votes' do
          ParliamentIssue.make! :external_id => non_personal_vote.external_issue_id

          inferrer = VoteInferrer.new([])

          Hdo::VoteInferrer.should_receive(:new).
                           with([kind_of(Vote)]).
                           and_return(inferrer)

          inferrer.should_receive(:infer!)

          persister.import_votes [non_personal_vote], infer: true
        end

      end
    end
  end
end
