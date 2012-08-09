require 'spec_helper'

module Hdo
  module Stats
    describe VoteCounts do
      let(:vote) { Vote.make! }

      it "calculates percentages"
      it 'returns a Hash with default 0 when fetching count for a non-existing party' do
        hash = vote.stats.party_counts_for('no-such-party')

        hash[:for].should == 0
        hash[:against].should == 0
        hash[:absent].should == 0
      end

      it 'it returns a string for an invalid party' do
        vote.stats.text_for(nil).should be_kind_of(String)
      end
    end
  end
end

