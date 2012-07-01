require 'spec_helper'

module Hdo
  module Stats
    describe TopicCounts do
      let(:topic) { Topic.make! }
      let(:topic_counts) { TopicCounts.new topic }
      let(:parties) { Array.new(2) { Party.make! } }

      before do
        Party.stub!(:all).and_return parties
      end

      it "calculates percentages for each party" do
        pending

        topic_counts.to_a.should == [
          [parties.first, 10],
          [parties.last,  80]
        ]
      end
    end
  end
end

