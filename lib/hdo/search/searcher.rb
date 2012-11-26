module Hdo
  module Search
    class Searcher
      SEARCH_ERRORS = [Tire::Search::SearchRequestFailed, Errno::ECONNREFUSED]

      INDECES = {
        Issue.index_name           => { boost: 5   },
        Party.index_name           => { boost: 3.5 },
        Representative.index_name  => { boost: 2   },
        Promise.index_name         => { boost: 1   },
        Proposition.index_name     => { boost: 1   },
        ParliamentIssue.index_name => { boost: 1   },
        Topic.index_name           => { boost: 2   },
      }

      AUTOCOMPLETE_INDECES = [Issue.index_name, Representative.index_name]

      def initialize(query)
        @query = query.blank? ? '*' : query
      end

      def all
        search = Tire.search(INDECES) do |s|
          s.size 100
          s.query do |query|
            query.string @query, default_operator: 'AND'
          end
          s.sort { by :_score }
        end

        Response.new(search.results)
      rescue *SEARCH_ERRORS => ex
        Rails.logger.error "search failed, #{ex.class} #{ex.message}"
        Response.new(nil, ex)
      end

      def autocomplete
        search = Tire.search(AUTOCOMPLETE_INDECES) do |s|
          s.size 25

          s.query do |query|
            query.string "#{@query}* #{@query}", default_operator: 'OR'
          end
          s.sort { by :_score }
        end

        Response.new(search.results)
      rescue *SEARCH_ERRORS => ex
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
      end

    end

  end
end
