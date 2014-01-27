require 'spec_helper'

module Hdo
  module Search
    describe Searcher do
      context 'all' do
        let(:query) { "some query" }
        let(:searcher) { Searcher.new(query) }

        it 'searches all indices for the given query' do
          Issue.should_receive(:search).with(
            hash_including(:query, :indices_boost),
            hash_including({size: 100, :index => ["hdo_test_issues", "hdo_test_parliament_issues", "hdo_test_parties", "hdo_test_promises", "hdo_test_propositions", "hdo_test_representatives"]})
          ).and_return(double(results: []))

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should be_success
          response.results.should == []
        end

        it 'returns a failed response if the search server is down' do
          Issue.should_receive(:search).and_raise Errno::ECONNREFUSED

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should_not be_success
          response.exception.should be_kind_of(Errno::ECONNREFUSED)
          response.results.should be_nil
        end

        it 'returns a failed response if the search request fails' do
          Issue.should_receive(:search).and_raise Elasticsearch::Transport::Transport::Errors::InternalServerError

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should_not be_success
          response.exception.should be_kind_of(Elasticsearch::Transport::Transport::Errors::InternalServerError)
          response.results.should be_nil
        end
      end

      context 'autocomplete' do
        def expect_query(input, opts = {})
          expected_query = opts[:expected_query] || anything
          expected_indices = opts[:expected_indices] || anything
          expected_size = opts[:expected_size] || anything

          searcher = Searcher.new(input)

          Issue.should_receive(:search).
            with(
              hash_including(query: {query_string: {query: expected_query, default_operator: 'OR'}}),
              hash_including(index: expected_indices, size: expected_size)
            ).and_return(double(results: []))

          searcher.autocomplete
        end

        it 'matches both wildcard and full string' do
          expect_query "LOL", expected_query: "LOL* LOL"
        end

        it 'only searches in issues and representative indeces' do
          expect_query "LOL", expected_indices: [Issue.index_name, Representative.index_name]
        end

        it 'restricts response size to 25' do
          expect_query "LOL", expected_size: 25
        end

        it 'removes trailing spaces' do
          # https://github.com/holderdeord/hdo-site/issues/614
          expect_query 'sykkel ', expected_query: 'sykkel* sykkel'
        end

      end
    end
  end
end
