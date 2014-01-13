module Hdo
  module Search
    class Searcher
      INDECES = {
        Issue.index_name           => { boost: 5   },
        Party.index_name           => { boost: 3.5 },
        Representative.index_name  => { boost: 2   },
        Promise.index_name         => { boost: 1   },
        Proposition.index_name     => { boost: 1   },
        ParliamentIssue.index_name => { boost: 1   }
      }

      def initialize(query, size = nil)
        @query = query.blank? ? '*' : query.strip
        @size = size || 100
      end

      def all
        response_from {
          Tire.search(INDECES) do |s|
            s.size @size
            s.query do |query|
              query.string @query, default_operator: 'AND'
            end
            s.sort { by :_score }
          end
        }
      end

      def promises
        response_from {
          Tire.search(Promise.index_name) do |s|
            s.size @size

            s.query do |query|
              query.string @query, default_operator: 'AND'
            end

            s.filter :term, parliament_period_name: '2013-2017'

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

      def propositions(params = {})
        Proposition.search(page: params[:page] || 1, per_page: params[:per_page] || @size) do |s|
          if @query != '*'
            s.sort { by :_score }
          else
            s.sort do
              by :id, 'desc'
              by :vote_time, 'desc'
            end
          end

          s.query do |q|
            q.filtered do |fq|
              fq.query { |qq| qq.string @query }
              fq.filter :term, parliament_session_name: params[:parliament_session_name]
            end
          end

          s.filter :term, status: params[:status] if params[:status].present?
          s.facet(:status) { |f| f.terms :status }
        end
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
