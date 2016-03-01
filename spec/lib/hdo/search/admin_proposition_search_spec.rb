require 'spec_helper'

module Hdo
  module Search
    describe AdminPropositionSearch do
      let(:response) { double.as_null_object }

      it 'handles an empty query' do
        expect(Proposition).to receive(:search).and_wrap_original do |m, body|
          body[:query][:filtered][:query][:query_string][:query].should == '*'
          response
        end

        AdminPropositionSearch.new(q: '')
      end
    end
  end
end
