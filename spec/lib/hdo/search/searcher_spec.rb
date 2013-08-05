require 'spec_helper'

module Hdo
  module Search
    describe Searcher do
      context 'all' do
        let(:query) { "some query" }
        let(:searcher) { Searcher.new(query) }
        let(:tire_search) { mock("tire search", sort: nil, results: []) }
        let(:tire_query) { mock("tire query") }

        it 'searches all indeces for the given query' do
          search = mock("search")
          Tire.should_receive(:search).
            with(hash_including(Issue.index_name)).
            and_yield(tire_search).and_return(tire_search)

          # testing a block DSL sucks...
          tire_search.should_receive(:size).and_return 25
          tire_search.should_receive(:query).and_yield(tire_query)
          tire_query.should_receive(:string).
            with(query, hash_including(default_operator: 'AND'))

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should be_success
          response.results.should == []
        end

        it 'returns a failed response if the search server is down' do
          Tire.should_receive(:search).and_raise Errno::ECONNREFUSED

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should_not be_success
          response.exception.should be_kind_of(Errno::ECONNREFUSED)
          response.results.should be_nil
        end

        it 'returns a failed response if the search request fails' do
          Tire.should_receive(:search).and_raise Errno::ECONNREFUSED

          response = searcher.all
          response.should be_kind_of(Searcher::Response)
          response.should_not be_success
          response.exception.should be_kind_of(Errno::ECONNREFUSED)
          response.results.should be_nil
        end
      end

      context 'autocomplete' do
        let(:tire_search) { mock("tire search", sort: nil, results: []) }
        let(:tire_query) { mock("tire query") }

        def expect_query(input, opts = {})
          search = mock("search")

          expected_query = opts[:expected_query] || anything
          expected_indeces = opts[:expected_indeces] || anything
          expected_size = opts[:expected_size] || anything

          searcher = Searcher.new(input)

          Tire.should_receive(:search).
            with(expected_indeces).
            and_yield(tire_search).and_return(tire_search)

          tire_search.should_receive(:size).with(expected_size)
          tire_search.should_receive(:query).and_yield(tire_query)
          tire_query.should_receive(:string).
            with(expected_query, hash_including(default_operator: 'OR'))

          searcher.autocomplete
        end


        it 'matches both wildcard and full string' do
          expect_query "LOL", expected_query: "LOL* LOL"
        end

        it 'only searches in issues and representative indeces' do
          expect_query "LOL", expected_indeces: [Issue.index_name, Representative.index_name]
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
