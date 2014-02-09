module Hdo
  module Search
    class Promises
      SEARCH_PARAMS = [:q, :category, :promisor, :parliament_period, :page]

      attr_reader :query
      attr_accessor :size

      def initialize(params)
        @query = params.slice(*SEARCH_PARAMS)
      end

      def merge(other)
        @query.merge other
      end

      def response
        @response ||= fetch
      end

      def promises
        response.page(page).records.includes(:issues, :promisor)
      end

      def navigators
        facets = response.response['facets']

        [
          Navigator.new(@query, :parliament_period, 'Periode', facets['parliament_period_name']),
          Navigator.new(@query, :promisor, 'Parti / Regjering', facets['promisor_name']),
          Navigator.new(@query, :category, 'Kategorier', facets['category_names'])
        ]
      end

      def open?
        vals = @query.except(:page).values
        vals.empty? || vals.all?(&:blank?)
      end

      def hits
        response.response['hits']['total']
      end

      def as_json
        response.results.map do |res|
          res._source.merge(id: res._id)
        end
      end

      SEARCH_PARAMS.each do |name|
        define_method("#{name}?") { @query[name].present? }
        define_method(name)       { @query[name]          }
      end

      private

      def page
        @query[:page] || 1
      end

      def fetch
        payload = {
          facets: {
            category_names: {
              terms: {field: 'category_names', all_terms: false, size: 250}
            },

            parliament_period_name: {
              terms: {field: 'parliament_period_name', all_terms: false, size: 20 }
            },

            promisor_name: {
              terms: {field: 'promisor_name', all_terms: false, size: 20 }
            },
          }
        }

        payload[:size] = @size if @size
        payload[:sort] = q.blank? ? {promisor_name: 'asc'} : :_score

        filters = []
        filters << {term: {category_names: category }} if category?
        filters << {term: {parliament_period_name: parliament_period }} if parliament_period?
        filters << {term: {promisor_name: promisor}} if promisor?

        qstring = {query_string: {query: q.blank? ? '*' : q, default_field: 'body', default_operator: 'AND'}}

        if filters.empty?
          payload[:query] = qstring
        else
          payload[:query] = {
            filtered: {
              query: qstring,
              filter: {and: filters}
            }
          }
        end

        Promise.search payload
      end

      class Navigator
        attr_reader :title, :param, :terms

        def initialize(query, param, title, data)
          @query = query[param]
          @title = title
          @param = param
          @total = data['total']
          @terms = data['terms'].sort_by { |e| e['term'] }

          @terms.reverse! if param == :parliament_period
        end

        def each_term(&blk)
          terms.each do |term|
            active = @query == term['term']

            yield term['term'], term['count'], active
          end
        end
      end

    end
  end
end
