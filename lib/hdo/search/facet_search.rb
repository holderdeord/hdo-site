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

        navs = facet_params.map do |param, opts|
          field = opts.fetch(:field).to_s
          title = opts.fetch(:title).to_s

          FacetNavigator.new self, @query, title, param, data[field]
        end

        navs.unshift KeywordNavigator.new(self, @query, 'Søk')

        navs
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
        results = response.results.map do |res|
          res._source.merge(id: res._id)
        end

        {
          navigators: navigators,
          results: results,
          next_url: (url(page: response.next_page) if response.next_page),
          previous_url: (url(page: response.prev_page) if response.prev_page),
          current_page: response.current_page,
          total_pages: response.total_pages
        }
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
        attr_reader :param, :title

        def initialize(search, query, title)
          @search = search
          @query  =  query
          @title  = title
        end

        def type
          raise 'subclass responsibility'
        end

        def keyword?
          type == :keyword
        end

        def facet?
          type == :facet
        end

        def as_json(opts = nil)
          {
            query: @query,
            title: @title,
            param: @param,
            type: {keyword: keyword?, facet: facet?}
          }
        end
      end

      class FacetNavigator < Navigator

        def initialize(search, query, title, param, data)
          super(search, query, title)

          @search = search
          @query  = query[param]
          @param  = param
          @title  = title
          @total  = data['total']
          @terms  = data['terms'].sort_by { |e| e['term'] }

          @terms.reverse! if [:parliament_period, :parliament_session].include? param
        end

        def type
          :facet
        end

        def as_json(opts = nil)
          terms = []
          each_term { |term| terms << term.to_hash }

          super.merge(terms: terms)
        end

        def each_term(&blk)
          terms.each(&blk)
        end

        def terms
          terms = []

          if @terms.empty? && @query
            terms << build(@query, 0, true)
          else
            @terms.each do |term|
              active = @query == term['term']

              terms << build(term['term'], term['count'], active)
            end
          end

          terms
        end

        private

        def build(name, count, active)
          m = Hashie::Mash.new(
            name: name,
            count: count,
            active: active,
            clear_url: @search.url(@param => nil, :page => nil),
            filter_url: @search.url(@param => name, :page => nil)
          )

          def m.count; self[:count]; end # avoid Hash#count

          m
        end
      end # FacetNavigator

      class KeywordNavigator < Navigator
        def initialize(search, query, title)
          super
          @param = :q
        end

        def type
          :keyword
        end

        def value
          @search.query[param]
        end

        def as_json(opts = nil)
          super.merge(
            filter_url: @search.url(q: '{query}', page: nil),
            value: value
          )
        end
      end # KeywordNavigator

    end # FacetSearch
  end # Search
end # Hdo
