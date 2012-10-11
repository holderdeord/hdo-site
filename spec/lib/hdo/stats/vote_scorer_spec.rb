# encoding: UTF-8

require 'spec_helper'

module Hdo
  module Stats
    describe VoteScorer do
      let(:issue)  { Issue.create!(:title => "issue") }
      let(:scorer) { VoteScorer.new issue }

      let(:rep1) { Representative.make!(:full) }
      let(:rep2) { Representative.make!(:full) }

      it 'calculates scores for a single vote' do
        # issue has one vote, with one rep for and one against
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.score_for(rep1.current_party).should == 100
        scorer.score_for(rep2.current_party).should == 0
      end

      it "calculates scores for a single vote that doesn't match the issue" do
        # issue has one vote, with one rep for and one against
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote does not match the issue
        issue.vote_connections.create! :vote => vote, :matches => false, :weight => 1

        scorer.score_for(rep1.current_party).should == 0
        scorer.score_for(rep2.current_party).should == 100
      end

      it 'calculates scores for a two votes with different weights' do
        # first vote matches the issue with weight=2
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 2

        # second vote does not match the issue and has weight=1
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => 1)
        ])

        # the vote does not match the issue
        issue.vote_connections.create! :vote => vote, :matches => false, :weight => 1

        scorer.score_for(rep1.current_party).should == 66
        scorer.score_for(rep2.current_party).should == 0
      end

      it 'has a string description of all valid scores' do
        p1 = Party.make!

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(p1).and_return 0
          scorer.text_for(p1).should == "#{p1.name} har stemt konsekvent mot"

          scorer.stub(:score_for).with(p1).and_return 20.1
          scorer.text_for(p1).should == "#{p1.name} har stort sett stemt mot"

          scorer.stub(:score_for).with(p1).and_return 39
          scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

          scorer.stub(:score_for).with(p1).and_return 40
          scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

          scorer.stub(:score_for).with(p1).and_return 60
          scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

          scorer.stub(:score_for).with(p1).and_return 79
          scorer.text_for(p1).should == "#{p1.name} har stort sett stemt for"

          scorer.stub(:score_for).with(p1).and_return 80
          scorer.text_for(p1).should == "#{p1.name} har stort sett stemt for"

          scorer.stub(:score_for).with(p1).and_return 100
          scorer.text_for(p1).should == "#{p1.name} har stemt konsekvent for"

          scorer.stub(:score_for).with(p1).and_return nil
          scorer.text_for(p1).should == "#{p1.name} har ikke deltatt i avstemninger om"
        end
      end

      it 'returns an HTML version of the description if :html => true' do
        p1 = Party.make!

        I18n.with_locale :nb do
          scorer.stub(:score_for).with(p1).and_return 0
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har stemt <strong>konsekvent mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 25
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har <strong>stort sett stemt mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 50
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har stemt <strong>både for og mot</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 79
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har <strong>stort sett stemt for</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return 100
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har stemt <strong>konsekvent for</strong>"
          str.should be_html_safe

          scorer.stub(:score_for).with(p1).and_return nil
          str = scorer.text_for(p1, :html => true)
          str.should == "#{p1.name} har ikke deltatt i avstemninger om"
          str.should be_html_safe
        end
      end


      it 'raises an error if the score is invalid' do
        scorer.stub(:score_for).and_return :foo
        lambda { scorer.text_for(:foo) }.should raise_error
      end

      it 'calculates score for a party grouping' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.score_for_group([rep1.current_party, rep2.current_party]).should eq 50
      end

      it 'uses group name as a text in text_for when group_name option is given' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.text_for_group([rep1.current_party, rep2.current_party], name: 'Ze Germans').should start_with 'Ze Germans'
      end

      it 'allows you to overwrite the party name' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the issue
        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.text_for(rep1.current_party, name: 'Ze Frenchies').should start_with 'Ze Frenchies'
      end

      it 'returns a nil score for a non-existing party' do
        scorer.score_for(:foo).should == nil
      end

      it 'returns a nil score for an empty group' do
        scorer.score_for_group([]).should == nil
      end

      it 'returns 0 scores when all votes are weighted 0' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 0

        scorer.score_for(rep1.current_party).should == 0
      end

      it 'correctly handles rebel votes' do
        rep2 = Representative.make!
        rep2.party_memberships.make!(:party => rep1.current_party)

        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        issue.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.score_for(rep1.current_party).should == 50
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

    end
  end
end
