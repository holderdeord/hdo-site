module Hdo
  module Search
    class Searcher
      BOOST = {
        Issue.index_name           => 5,
        Party.index_name           => 3.5,
        Representative.index_name  => 2,
        Promise.index_name         => 1,
        Proposition.index_name     => 1,
        ParliamentIssue.index_name => 1
      }

      def initialize(query, size = nil)
        @query  = query.blank? ? '*' : query.strip
        @size   = size || 100
      end

      def all
        q = {
          query: {
            query_string: {query: @query, default_operator: 'AND'}
          },
          indices_boost: BOOST
        }

        indices = (SearchSettings.models - [Vote]).map(&:index_name)

        opts = {
          index: indices,
          type: nil,
          size: @size,
          sort: ['_score']
        }

        response_from { Issue.search(q, opts) }
      end

      def promises
        q = {
          query: {
            query_string: {query: @query, default_operator: 'AND'}
          },
          filter: {term: {parliament_period_name: '2013-2017' } }
        }

        opts = {
          size: @size,
          sort: ['_score']
        }

        response_from { Promise.search(q, opts) }
      end

      def autocomplete
        q = {
          query: {
            query_string: {query: "#{@query}* #{@query}", default_operator: 'OR'}
          }
        }

        opts = {
          index: [Issue, Representative].map(&:index_name),
          type: nil,
          size: 25,
          sort: ['_score']
        }

        response_from { Issue.search(q, opts) }
      end

      def proposition_histogram(opts = {})
        start_time = opts[:start] || 6.months.ago

        q = {
          facets: {
            counts: {
              date_histogram: { field: 'vote_time', interval: '1w' },
              global: true,
              facet_filter: {
                fquery: {
                  query: {
                    filtered: {
                      query: {query_string: {query: @query }}
                    },
                    filter: {
                      bool: {
                        must: [
                          {match_all: {}},
                          {terms: {_type: ['proposition']}},
                          {
                            range: {
                              vote_time: { from: (start_time.to_f * 1000).to_i }
                            }
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          }
        }

        response_from { Proposition.search(q, size: 0) }
      end

      private

      SEARCH_ERRORS = [
        Elasticsearch::Transport::Transport::Errors::InternalServerError,
        Errno::ECONNREFUSED
      ]

      def response_from(&blk)
        Response.new(yield)
      rescue *SEARCH_ERRORS => ex
        Rails.logger.error "search failed, #{ex.class} #{ex.message}"
        Response.new(nil, ex)
      end

      class Response
        attr_reader :results, :exception

        def initialize(response, exception = nil)
          @response = response
          @exception = exception
        end

        def facets
          Hashie::Mash.new @response.response['facets']
        end

        def results
          @response.results
        end

        def success?
          !@exception
        end

        def down?
          @exception.kind_of? Errno::ECONNREFUSED
        end
      end # Response

    end # Searcher
  end
end
