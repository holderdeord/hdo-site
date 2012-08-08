# encoding: UTF-8

require 'spec_helper'

module Hdo
  module Stats
    describe VoteScorer do
      let(:topic)  { Topic.create!(:title => "topic") }
      let(:scorer) { VoteScorer.new topic }

      let(:rep1) { Representative.make! }
      let(:rep2) { Representative.make! }

      it 'calculates scores for a single vote' do
        # topic has one vote, with one rep for and one against
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the topic
        topic.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.score_for(rep1.party).should == 100
        scorer.score_for(rep2.party).should == 0
      end

      it "calculates scores for a single vote that doesn't match the topic" do
        # topic has one vote, with one rep for and one against
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote does not match the topic
        topic.vote_connections.create! :vote => vote, :matches => false, :weight => 1

        scorer.score_for(rep1.party).should == 0
        scorer.score_for(rep2.party).should == 100
      end

      it 'calculates scores for a two votes with different weights' do
        # first vote matches the topic with weight=2
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        topic.vote_connections.create! :vote => vote, :matches => true, :weight => 2

        # second vote does not match the topic and has weight=1
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => 1)
        ])

        # the vote does not match the topic
        topic.vote_connections.create! :vote => vote, :matches => false, :weight => 1

        scorer.score_for(rep1.party).should == 66
        scorer.score_for(rep2.party).should == 0
      end

      it 'has a string description of all valid scores' do
        p1 = Party.make!

        scorer.stub(:score_for).with(p1).and_return 0
        scorer.text_for(p1).should == "#{p1.name} har stemt mot"

        scorer.stub(:score_for).with(p1).and_return 33.4
        scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

        scorer.stub(:score_for).with(p1).and_return 50
        scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

        scorer.stub(:score_for).with(p1).and_return 65
        scorer.text_for(p1).should == "#{p1.name} har stemt både for og mot"

        scorer.stub(:score_for).with(p1).and_return 66.2
        scorer.text_for(p1).should == "#{p1.name} har stemt for"

        scorer.stub(:score_for).with(p1).and_return 67
        scorer.text_for(p1).should == "#{p1.name} har stemt for"

        scorer.stub(:score_for).with(p1).and_return 100
        scorer.text_for(p1).should == "#{p1.name} har stemt for"

        scorer.stub(:score_for).with(p1).and_return nil
        scorer.text_for(p1).should == "#{p1.name} har ikke deltatt i avstemninger om tema"
      end

      it 'returns an HTML version of the description if :html => true' do
        p1 = Party.make!

        scorer.stub(:score_for).with(p1).and_return 0
        str = scorer.text_for(p1, :html => true)
        str.should == "#{p1.name} har stemt <strong>mot</strong>"
        str.should be_html_safe

        scorer.stub(:score_for).with(p1).and_return 50
        str = scorer.text_for(p1, :html => true)
        str.should == "#{p1.name} har stemt <strong>både for og mot</strong>"
        str.should be_html_safe

        scorer.stub(:score_for).with(p1).and_return 100
        str = scorer.text_for(p1, :html => true)
        str.should == "#{p1.name} har stemt <strong>for</strong>"
        str.should be_html_safe

        scorer.stub(:score_for).with(p1).and_return nil
        str = scorer.text_for(p1, :html => true)
        str.should == "#{p1.name} har ikke deltatt i avstemninger om tema"
        str.should be_html_safe
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

        # the vote matches the topic
        topic.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.score_for_group([rep1.party, rep2.party]).should eq 50
      end

      it 'uses group name as a text in text_for when group_name option is given' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the topic
        topic.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.text_for_group([rep1.party, rep2.party], name: 'Ze Germans').should start_with 'Ze Germans'
      end

      it 'allows you to overwrite the party name' do
        vote = Vote.make!(:vote_results => [
          VoteResult.new(:representative => rep1, :result => 1),
          VoteResult.new(:representative => rep2, :result => -1)
        ])

        # the vote matches the topic
        topic.vote_connections.create! :vote => vote, :matches => true, :weight => 1

        scorer.text_for(rep1.party, name: 'Ze Frenchies').should start_with 'Ze Frenchies'
      end

      it 'returns a nil score for a non-existing party' do
        scorer.score_for(:foo).should == nil
      end

      it 'returns a nil score for an empty group' do
        scorer.score_for_group([]).should == nil
      end

    end
  end
end
