module Hdo
  module Search
    class Searcher
      SEARCHABLE_MODELS = [Issue, Party, Representative, Promise, Proposition, ParliamentIssue]

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
        @client = Elasticsearch::Model.client
      end

      def all
        q = {
          query: {
            query_string: {query: @query, default_operator: 'AND'}
          },
          indices_boost: BOOST
        }

        opts = {
          index: SEARCHABLE_MODELS.map(&:index_name),
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

      def propositions(params = {})
        Proposition.search(page: params[:page] || 1, per_page: params[:per_page] || @size) do |s|
          if @query != '*'
            s.sort { by :_score }
          else
            s.sort do
              by :id, 'asc'
              by :vote_time, 'asc'
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

      SEARCH_ERRORS = [
        Elasticsearch::Transport::Transport::Errors::InternalServerError,
        Errno::ECONNREFUSED
      ]

      def response_from(&blk)
        search = yield
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
      end # Response

    end # Searcher
  end
end
