# encoding: UTF-8

require 'spec_helper'

module Hdo
  module Stats
    describe VoteScorer do
      let(:issue)  { Issue.create!(title: "issue") }
      let(:scorer) { VoteScorer.new issue }

      let(:rep1) { Representative.make!(:full) }
      let(:rep2) { Representative.make!(:full) }

      it 'calculates scores for a single vote' do
        # issue has one vote, with one rep for and one against
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.score_for(rep1.current_party).should == 100
        scorer.score_for(rep2.current_party).should == 0

        scorer.score_for(rep1).should == 100
        scorer.score_for(rep2).should == 0
      end

      it "calculates scores for a single vote that doesn't match the issue" do
        # issue has one vote, with one rep for and one against
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        # the vote does not match the issue
        issue.vote_connections.create! vote: vote, matches: false, weight: 1

        scorer.score_for(rep1.current_party).should == 0
        scorer.score_for(rep2.current_party).should == 100

        scorer.score_for(rep1).should == 0
        scorer.score_for(rep2).should == 100
      end

      it 'calculates scores for two votes with different weights' do
        # first vote matches the issue with weight=2
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        issue.vote_connections.create! vote: vote, matches: true, weight: 2

        # second vote does not match the issue and has weight=1
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: 1)
        ])

        # the vote does not match the issue
        issue.vote_connections.create! vote: vote, matches: false, weight: 1

        scorer.score_for(rep1.current_party).should == 66
        scorer.score_for(rep2.current_party).should == 0

        scorer.score_for(rep1).should == 66
        scorer.score_for(rep2).should == 0
      end

      it 'has a string description of all valid scores' do
        p1 = Party.make!

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(p1).and_return 0
          scorer.text_for(p1).should == "#{p1.name} har stemt mot"

          scorer.stub(:score_for).with(p1).and_return 4.5
          scorer.text_for(p1).should == "#{p1.name} har stemt mot"

          scorer.stub(:score_for).with(p1).and_return 32.1
          scorer.text_for(p1).should == "#{p1.name} har stemt mot"

          scorer.stub(:score_for).with(p1).and_return 33
          scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

          scorer.stub(:score_for).with(p1).and_return 65.2
          scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

          scorer.stub(:score_for).with(p1).and_return 66
          scorer.text_for(p1).should == "#{p1.name} har stemt for"

          scorer.stub(:score_for).with(p1).and_return 81.2
          scorer.text_for(p1).should == "#{p1.name} har stemt for"

          scorer.stub(:score_for).with(p1).and_return 100
          scorer.text_for(p1).should == "#{p1.name} har stemt for"

          scorer.stub(:score_for).with(p1).and_return nil
          scorer.text_for(p1).should == "#{p1.name} har ikke deltatt i avstemninger om"
        end
      end

      it 'has a string description for a representative' do
        scorer.stub(:score_for).with(rep1).and_return 100

        I18n.with_locale :nb do
          scorer.text_for(rep1).should == "#{rep1.name} har stemt for"
        end
      end

      it 'returns an HTML version of the description if :html => true' do
        p1 = Party.make!

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(p1).and_return 0
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 4.5
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 32.1
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 33
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>både for og mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 65.2
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>både for og mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 66
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>for</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 81.2
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>for</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 100
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har stemt <strong>for</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return nil
          str = scorer.text_for(p1, html: true)
          str.should == "#{p1.name} har ikke deltatt i avstemninger om"
          str.should be_html_safe
        end
      end

      it "has a text representation of an entity's score" do
        party = stub

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(party).and_return 33
          scorer.text_score_for(party).should == '33%'

          scorer.stub(:score_for).with(party).and_return nil
          scorer.text_score_for(party).should == 'Uvisst'
        end
      end

      it 'raises an error if the score is invalid' do
        scorer.stub(:score_for).and_return :foo
        lambda { scorer.text_for(:foo) }.should raise_error
      end

      it 'calculates score for a groupings' do
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.score_for_group([rep1.current_party, rep2.current_party]).should eq 50
        scorer.score_for_group([rep1, rep2]).should eq 50
      end

      it 'uses group name as a text in text_for when group_name option is given' do
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.text_for_group([rep1.current_party, rep2.current_party], name: 'Ze Germans').should start_with 'Ze Germans'
      end

      it 'allows you to overwrite the party name' do
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.text_for(rep1.current_party, name: 'Ze Frenchies').should start_with 'Ze Frenchies'
      end

      it 'returns a nil score for a non-existing party' do
        scorer.score_for(:foo).should == nil
      end

      it 'returns a nil score for an empty group' do
        scorer.score_for_group([]).should == nil
      end

      it 'returns 0 scores when all votes are weighted 0' do
        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        issue.vote_connections.create! vote: vote, matches: true, weight: 0

        scorer.score_for(rep1.current_party).should == 0
      end

      it 'correctly handles rebel votes' do
        rep2 = Representative.make!
        rep2.party_memberships.make!(party: rep1.current_party)

        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.score_for(rep1.current_party).should == 50

        scorer.score_for(rep1).should == 100
        scorer.score_for(rep2).should == 0
      end

      it 'is not affected by absence' do
        vote1 = Vote.make!(vote_results: [VoteResult.new(representative: rep1, result: 1)])
        vote2 = Vote.make!(vote_results: [VoteResult.new(representative: rep1, result: 0)])

        issue.vote_connections.create! vote: vote1, matches: true, weight: 1
        issue.vote_connections.create! vote: vote2, matches: true, weight: 1

        scorer.score_for(rep1.current_party).should == 100
        scorer.score_for(rep1).should == 100
      end

      it 'treats votes against alternate budgets as absent' do
        vote = Vote.make!(vote_results: [VoteResult.new(representative: rep1, result: -1)])
        issue.vote_connections.create! vote: vote, matches: true, weight: 1, proposition_type: 'alternate_national_budget'

        scorer.score_for(rep1).should be_nil
      end

      it 'ignores positive rebels on alternate budgets (50/50)' do
        # see https://github.com/holderdeord/hdo-site/issues/520
        party = rep1.current_party

        rep2 = Representative.make!
        rep2.party_memberships.make!(party: party)

        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1)
        ])

        issue.vote_connections.create! vote: vote, matches: true, weight: 1, proposition_type: 'alternate_national_budget'

        scorer.score_for(rep1).should == 100  # voted for
        scorer.score_for(rep2).should == nil  # voted against, treated as absent
        scorer.score_for(party).should == nil # positive rebel vote for ignored
      end

      it 'ignores positive rebels on alternate budgets (>50%)' do
        # see https://github.com/holderdeord/hdo-site/issues/520
        party = rep1.current_party

        rep2 = Representative.make!
        rep2.party_memberships.make!(party: party)

        rep3 = Representative.make!
        rep3.party_memberships.make!(party: party)

        vote = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: -1),
          VoteResult.new(representative: rep3, result: -1)
        ])

        issue.vote_connections.create! vote: vote, matches: false, weight: 1, proposition_type: 'alternate_national_budget'

        scorer.score_for(rep1).should == 0   # voted for
        scorer.score_for(rep2).should == nil # voted against, treated as absent
        scorer.score_for(rep3).should == nil # voted against, treated as absent
        scorer.score_for(party).should == nil # positive rebel vote for ignored
      end

      it "uses the representative's party membership at vote time" do
        p1 = Party.make!
        p2 = Party.make!

        rep = Representative.make!

        rep.party_memberships.create!(start_date: 10.days.ago, end_date: 2.days.ago, party: p1)
        rep.party_memberships.create!(start_date: 1.day.ago,   end_date: nil,        party: p2)

        vote = Vote.make!(time: 5.days.ago,
                          vote_results: [VoteResult.new(representative: rep, result: 1)])

        issue.vote_connections.create! vote: vote, matches: true, weight: 1

        scorer.score_for(rep.current_party).should be_nil
        scorer.score_for(p1).should == 100
      end

      it "does computation up front" do
        party     = Party.make!
        ivar_size = scorer.instance_variables.size

        scorer.score_for(party)
        scorer.instance_variables.size.should == ivar_size

        scorer.score_for_group [party]
        scorer.instance_variables.size.should == ivar_size
      end

      it 'has a JSON representation' do
        scorer.as_json.should be_kind_of(Hash)
      end

      it 'generates CSV to analyze weights' do
        Issue.make!(status: 'published')
        Issue.make!(status: 'published')

        VoteScorer.csv.should be_kind_of(String)
      end

      it 'does not count representatives that participated in less than 50% of votes on issue' do
        rep2 = Representative.make!

        vote1 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: 1)
        ])

        vote2 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep2, result: 1)
        ])

        vote3 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep2, result: 1)
        ])

        issue.vote_connections.create! vote: vote1, matches: true, weight: 1
        issue.vote_connections.create! vote: vote2, matches: true, weight: 1
        issue.vote_connections.create! vote: vote3, matches: true, weight: 1

        VoteScorer.new(issue).score_for(rep1).should be_nil
      end

      it 'does count representatives that participated in 50% of votes on issue' do
        rep2 = Representative.make!

        vote1 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: 1)
        ])
        vote2 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
          VoteResult.new(representative: rep2, result: 1)
        ])
        vote3 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep2, result: 1)
        ])
        vote4 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep2, result: 1)
        ])

        issue.vote_connections.create! vote: vote1, matches: true, weight: 1
        issue.vote_connections.create! vote: vote2, matches: true, weight: 1
        issue.vote_connections.create! vote: vote3, matches: true, weight: 1
        issue.vote_connections.create! vote: vote4, matches: true, weight: 1

        VoteScorer.new(issue).score_for(rep1).should_not be_nil
      end

      it "takes 'absent' vote results into account" do
        vote1 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 1),
        ])

        vote2 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 0)
        ])

        vote3 = Vote.make!(vote_results: [
          VoteResult.new(representative: rep1, result: 0)
        ])

        issue.vote_connections.create! vote: vote1, matches: true, weight: 1
        issue.vote_connections.create! vote: vote2, matches: true, weight: 1
        issue.vote_connections.create! vote: vote3, matches: true, weight: 1

        VoteScorer.new(issue).score_for(rep1).should == 100
      end

    end
  end
end
