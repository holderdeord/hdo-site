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

      it 'raises an error if the score is invalid' do
        scorer.stub(:score_for).and_return :foo
        lambda { scorer.text_for(:foo) }.should raise_error
      end

    end
  end
end

