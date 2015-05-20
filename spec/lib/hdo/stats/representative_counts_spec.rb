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
      let(:counts) { RepresentativeCounts.new(vote_results) }

      it 'knows the absent count' do
        counts.absent_count.should == 1
      end

      it 'knows the for count' do
        counts.for_count.to_i.should == 3
      end

      it 'knows the against count' do
        counts.against_count.should == 2
      end

      it 'knows the absent percent' do
        counts.absent_percent.to_i.should == 16
      end

      it 'knows the for percent' do
        counts.for_percent.should == 50
      end

      it 'knows the against percent' do
        counts.against_percent.to_i.should == 33
      end
    end
  end
end
