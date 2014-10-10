require 'spec_helper'

module Hdo
  module Stats
    describe RepresentativeCounts do
      let(:vote_results) {
        [
          double(result: 1),
          double(result: 1),
          double(result: 1),
          double(result: 0),
          double(result: -1),
          double(result: -1),
        ]
      }
      let(:vote)  { double(vote_results: vote_results) }
      let(:counts) { RepresentativeCounts.new(vote) }

      it 'knows the absent count' do
        counts.absent_count.should == 1
      end

      it 'knows the for count' do
        counts.for_count.should == 3
      end

      it 'knows the against count' do
        counts.against_count.should == 2
      end

      it 'knows the absent percent' do
        counts.absent_percent.should == 16
      end

      it 'knows the for percent' do
        counts.for_percent.should == 50
      end

      it 'knows the against percent' do
        counts.against_percent.should == 33
      end
    end
  end
end
