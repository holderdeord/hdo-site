module Hdo
  module Stats
    class PropositionCounts
      def self.from_session(session_name)
        q = {
          query: {
            filtered: {
              query: {query_string: {query: '*'}},
              filter: {
                and: [
                  {term: {parliament_session_name: session_name }}
                ]
              }
            },
          },
          facets: {status: {terms: {field: "status", size: 10, all_terms: false}}}
        }

        search = Proposition.search(q, search_type: 'count')
        new search.response['facets']
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
        total.zero? ? 0 : (published / total.to_f) * 100
      end

      def pending_percentage
        total.zero? ? 0: (pending / total.to_f) * 100
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
