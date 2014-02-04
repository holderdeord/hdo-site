require './lib/hdo/stats/proposition_counts'

module Hdo
  module Stats
    describe PropositionCounts do
      let(:counts) { PropositionCounts.new(facets) }

      let(:facets) do
        {
          'status' => {
            'total' => 100,
            'terms' => [
              {'term' => 'published', 'count' => 20},
              {'term' => 'pending', 'count' => 80},
            ]
          }
        }
      end

      it 'calculates percentages' do
        counts.published_percentage.should == 20
        counts.pending_percentage.should == 80
      end

      it 'calculates counts' do
        counts.published.should == 20
        counts.pending.should == 80
        counts.total.should == 100
      end

    end
  end
end

