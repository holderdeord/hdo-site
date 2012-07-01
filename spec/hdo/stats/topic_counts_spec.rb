require 'spec_helper'

module Hdo
  module Stats
    describe TopicCounts do
      let(:topic) { Topic.make! }
      let(:topic_counts) { TopicCounts.new topic }
      let(:parties) { [Party.make!, Party.make!] }

      before do
        Party.stub!(:all).and_return parties
      end

      it "calculates percentages for each party" do

      end
    end
  end
end

