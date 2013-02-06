require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'votes' do

        include_context :persister

        def setup_vote(vote)
          vote.representatives.each do |rep|
            rep.committees.each do |c|
              Committee.make!(:external_id => c.external_id) unless Committee.find_by_external_id(c.external_id)
            end

            rep.parties.each do |p|
              Party.make!(:external_id => p.external_id) unless Party.find_by_external_id(p.external_id)
            end

            District.make!(:name => rep.district) unless District.find_by_name(rep.district)
          end

          ParliamentIssue.make!(:external_id => vote.external_issue_id) unless ParliamentIssue.find_by_external_id(vote.external_issue_id)
        end

        let :non_personal_vote do
          vote_as_hash = StortingImporter::Vote.example('personal' => false, 'representatives' => []).to_hash
          vote_as_hash['propositions'][0]['deliveredBy'] = nil # less stubbing.
          vote_as_hash['counts'] = {'for' => 0, 'against' => 0, 'absent' => 0}

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

        it 'handles comma-separated list of external issue ids' do
          vote = StortingImporter::Vote.example
          setup_vote(vote)

          ParliamentIssue.make! :external_id => '512'
          vote.external_issue_id << ",512"

          persister.import_vote vote
          Vote.count.should == 1
          Vote.first.parliament_issues.map(&:external_id).should include('512')
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

        it 'does not overwrite vote counts for already inferred votes' do
          setup_vote non_personal_vote
          persister.import_votes [non_personal_vote]

          Vote.count.should == 1
          vote = Vote.first

          # a non personal vote is inferred if it has vote_results
          vote.vote_results.create!(representative: Representative.make!, result: 1)
          vote.update_attributes!(for_count: 1)

          persister.import_votes [non_personal_vote]

          vote.reload.for_count.should == 1
        end

        it 'updates an existing vote based on external id' do
          example = StortingImporter::Vote.example
          setup_vote(example)
          persister.import_vote example

          Vote.count.should == 1

          update = StortingImporter::Vote.example.to_hash
          update['representatives'] << StortingImporter::Representative.example(
            'externalId' => 'JD',
            'firstName'  => 'John',
            'lastName'   => 'Doe',
            'voteResult' => 'for'
          ).to_hash

          update['counts']['for'] += 1

          persister.import_vote StortingImporter::Vote.from_hash(update)

          Vote.count.should == 1

          vote = Vote.first
          vote.for_count.should == update['counts']['for']

          expected = [example.representatives.first.last_name, 'Doe'].sort
          actual   = vote.vote_results.map { |e| e.representative.last_name }.sort

          actual.should == expected
        end

        it "updates an existing vote based on timestamp if it's not an alternate vote" do
          # see https://github.com/holderdeord/hdo-site/issues/317
          example = StortingImporter::Vote.example('propositions' => [])
          setup_vote(example)
          persister.import_vote example

          Vote.count.should == 1

          new_xid = (example.external_id.to_i + 1).to_s
          update = StortingImporter::Vote.example('externalId' => new_xid)

          persister.import_vote update

          Vote.count.should == 1
        end

        it 'updates an existing alternate vote' do
          time    = 2.days.ago.to_s
          subject = 'Alternativ votering'

          v1 = StortingImporter::Vote.example(
            'externalId' => '1',
            'counts'     => {'for' => 1, 'against' => 168, 'absent' => 0},
            'time'       => time,
            'subject'    => subject,
            'enacted'    => false
          )

          v2 = StortingImporter::Vote.example(
            'externalId' => '2',
            'counts'     => {'for' => 168, 'against' => 1, 'absent' => 0},
            'time'       => time,
            'subject'    => subject,
            'enacted'    => true
          )

          setup_vote v1
          setup_vote v2

          persister.import_votes [v1, v2]
          Vote.count.should == 2

          v3 = StortingImporter::Vote.example(
            'externalId' => '3',
            'counts'     => {'for' => 168, 'against' => 1, 'absent' => 0},
            'time'       => time,
            'subject'    => subject,
            'enacted'    => true
          )

          persister.import_vote v3
          Vote.count.should == 2

          a, b = Vote.all
          a.should be_alternate_of(b)

          [a.external_id, b.external_id].sort.should == %w[1 3]
        end

        it 'imports a vote twice without adding duplicate propositions' do
          example = StortingImporter::Vote.example
          setup_vote(example)

          2.times do
            persister.import_vote example
            Vote.connection.select_all('select * from propositions_votes').size.should == example.propositions.size
          end
        end

        it 'imports a vote twice without adding duplicate parliament issues' do
          example = StortingImporter::Vote.example
          setup_vote(example)

          2.times do
            persister.import_vote example
            Vote.connection.select_all('select * from parliament_issues_votes').size.should == 1
          end
        end

      end
    end
  end
end
