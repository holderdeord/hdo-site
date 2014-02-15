module Hdo
  module Search
    module FacetSearch
      extend ActiveSupport::Concern

      included do
        attr_reader :query
        attr_accessor :size

        # defaults
        search_param :q
        search_param :page
      end

      module ClassMethods
        def paginates_per(n = nil)
          @paginates_per = n if n
          @paginates_per
        end

        def search_param(name, opts = nil)
          search_params[name] = opts

          define_method("#{name}?") { @query[name].present? }
          define_method(name)       { @query[name]          }
        end

        def model(name = nil)
          @model = name if name
          @model or raise "must set model"
        end

        def search_params
          @search_params ||= {}
        end

        def default_sort(*args)
          case args.size
          when 0
            @default_sort
          when 1
            @default_sort = args.first
          when 2
            @default_sort = {args.first => args.last }
          else
            raise ArgumentError, "invalid arguments: #{args.inspect}"
          end
        end

        def default_field(field = nil)
          @default_field = field if field
          @default_field
        end
      end # ClassMethods

      def initialize(params, view_context)
        @query        = params.slice(*self.class.search_params.keys)
        @view_context = view_context
      end

      def url(params = {})
        view_context.url_for @query.merge(params)
      end

      def response
        @response ||= fetch
      end

      def navigators
        data = response.response['facets']

        facet_params.map do |name, opts|
          field = opts.fetch(:field).to_s
          title = opts.fetch(:title).to_s

          Navigator.new @query, name, title, data[field]
        end
      end

      def records
        response.records
      end

      def model
        self.class.model
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

      private

      attr_reader :view_context

      def page
        @query[:page] || 1
      end

      def size
        @size || self.class.paginates_per || 25
      end

      def fetch
        payload = {}
        payload[:size] = size

        payload.merge! facets

        if q.blank?
          payload[:sort] = self.class.default_sort || :_score
          query          = {match_all: {}}
        else
          payload[:sort] = :_score

          query = {
            query_string: {
              query: q,
              default_field: self.class.default_field || '_all',
              default_operator: 'AND'
            }
          }
        end

        if filters.empty?
          payload[:query] = query
        else
          payload[:query] = {
            filtered: {
              query: query,
              filter: {and: filters}
            }
          }
        end

        model.search(payload).page(page).per(size)
      end

      def filters
        @filters ||= (
          filters = []

          facet_params.each do |name, opts|
            field = opts.fetch(:field)
            filters << {term: {field => @query[name] }} if @query[name].present?
          end

          filters
        )
      end

      def facet_params
        @facet_params ||= self.class.search_params.select { |name, opts| opts && opts[:facet] }.map { |name, opts| [name, opts[:facet]] }
      end

      def facets
        @facets ||= (
          f = {}

          if facet_params.any?
            result = f[:facets] = {}

            facet_params.each do |name, opts|
              field = opts.fetch(:field)

              result[field] = {
                terms: {
                  field: field.to_s, all_terms: false, size: opts[:size] || 10
                }
              }
            end
          end

          f
        )
      end

      class Navigator
        attr_reader :title, :param, :terms

        def initialize(query, param, title, data)
          @query = query[param]
          @title = title
          @param = param
          @total = data['total']
          @terms = data['terms'].sort_by { |e| e['term'] }

          @terms.reverse! if [:parliament_period, :parliament_session].include? param
        end

        def each_term(&blk)
          if terms.empty? && @query
            yield @query, 0, true
          else
            terms.each do |term|
              active = @query == term['term']

              yield term['term'], term['count'], active
            end
          end
        end
      end # Navigator

    end # FacetSearch
  end # Search
end # Hdo