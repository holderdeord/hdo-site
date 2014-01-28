require 'spec_helper'

module Hdo
  module Search
    describe AdminPropositionSearch do
      let(:response) { double.as_null_object }

      it 'handles an empty query' do
        Proposition.should_receive(:search).with { |body|
          body[:query][:filtered][:query][:query_string][:query].should == '*'
        }.and_return(response)

        AdminPropositionSearch.new(q: '')
      end
    end
  end
end
