module Hdo
  module Search
    class Searcher
      INDECES = {
        Issue.index_name           => { boost: 5   },
        Party.index_name           => { boost: 3.5 },
        Representative.index_name  => { boost: 2   },
        Promise.index_name         => { boost: 1   },
        Proposition.index_name     => { boost: 1   },
        ParliamentIssue.index_name => { boost: 1   },
        Topic.index_name           => { boost: 2   },
      }

      def initialize(query)
        @query = query.blank? ? '*' : query
      end

      def all
        response_from {
          Tire.search(INDECES) do |s|
            s.size 100
            s.query do |query|
              query.string @query, default_operator: 'AND'
            end
            s.sort { by :_score }
          end
        }
      end

      def autocomplete
        response_from {
          Tire.search([Issue.index_name, Representative.index_name]) do |s|
            s.size 25

            s.query do |query|
              query.string "#{@query}* #{@query}", default_operator: 'OR'
            end
            s.sort { by :_score }
          end
        }
      end

      private

      def response_from(&blk)
        search = yield
        Response.new(search.results)
      rescue Tire::Search::SearchRequestFailed, Errno::ECONNREFUSED => ex
        Rails.logger.error "search failed, #{ex.class} #{ex.message}"
        Response.new(nil, ex)
      end

      class Response
        attr_reader :results, :exception

        def initialize(results, exception = nil)
          @results   = results
          @exception = exception
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
