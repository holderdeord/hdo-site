require 'spec_helper'

module Hdo
  module Stats
    describe VoteCounts do
      let(:vote) { Vote.make!(:for_count => 1, :against_count => 2, :absent_count => 3) }

      it 'returns a Hash with default 0 when fetching count for a non-existing party' do
        hash = vote.stats.party_counts_for('no-such-party')

        hash[:for].should == 0
        hash[:against].should == 0
        hash[:absent].should == 0
      end

      it 'it returns a string for an invalid party' do
        vote.stats.text_for(nil).should be_kind_of(String)
      end

      it "does computation up front" do
        # TODO: this spec knows too much about the implementation.

        stats = vote.stats
        ivar_size = stats.instance_variables.size

        stats.for_count.should == 1
        stats.instance_variables.size.should == ivar_size

        stats.for_percent.should == 33
        stats.instance_variables.size.should == ivar_size

        stats.party_counts_for(Party.make!)
        stats.instance_variables.size.should == ivar_size
      end

      it 'has a JSON representations' do
        vote.stats.as_json.should be_kind_of(Hash)
      end

    end
  end
end

