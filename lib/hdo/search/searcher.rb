module Hdo
  module Search
    class Searcher
      INDECES = {
        'issues'            => { boost: 5   },
        'parties'           => { boost: 3.5 },
        'representatives'   => { boost: 2   },
        'promises'          => { boost: 1   },
        'propositions'      => { boost: 1   },
        'parliament_issues' => { boost: 1   },
        'topics'            => { boost: 2   },
      }


      def initialize(params)
        @params = params
      end

      def all
        query = @params[:query].to_s

        search = Tire.search(INDECES) do |s|
          s.size 25

          s.query do |query|
            query.string query, default_operator: 'AND'
          end

          s.sort { by :_score }
        end

        Response.new(search.results)
      rescue Tire::Search::SearchRequestFailed => ex
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
      end
    end

  end
end