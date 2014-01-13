module Hdo
  module Stats
    class PropositionCounts
      def self.from_session(session_name)
        search = Proposition.search(search_type: 'count') {
          query {
            filtered {
              query { string '*' }
              filter :term, parliament_session_name: session_name
            }
          }

          facet(:status) { terms :status }
        }

        new search.facets
      end

      def initialize(facets)
        @data = Hash.new(0)

        status_facet = facets['status']
        @data[:total] = status_facet['total']

        status_facet['terms'].each do |term|
          @data[term['term'].to_sym] = term['count']
        end
      end

      def published_percentage
        (published / total.to_f) * 100
      end

      def pending_percentage
        (pending / total.to_f) * 100
      end

      def published
        @data[:published]
      end

      def pending
        @data[:pending]
      end

      def total
        @data[:total]
      end
    end

  end
end