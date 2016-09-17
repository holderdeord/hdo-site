module Hdo
  module Search
    module FacetSearch
      extend ActiveSupport::Concern

      included do
        attr_reader :query
        attr_writer :size

        # defaults
        search_param :q, title: 'Søk'
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
        @ignored      = []

        if params[:size] && params[:size].to_i > 0
          @size = params[:size].to_i
        end
      end

      def ignore(param)
        @ignored << param
      end

      def url(params = {})
        view_context.url_for @query.merge(params)
      end

      def response
        @response ||= fetch
      end

      def navigators
        data = response.response['aggregations']

        search_params.map do |param, opts|
          next if param == :page

          if opts[:facet]
            opts = opts[:facet]

            title = opts.fetch(:title).to_s
            field = opts.fetch(:field).to_s

            FacetNavigator.new self, @query, title, param, data[field]
          elsif param == :q
            KeywordNavigator.new self, @query, opts.fetch(:title), param
          elsif opts[:boolean]
            BooleanNavigator.new self, @query, opts.fetch(:title), param
          else
            raise "unknown search param type: #{param}"
          end
        end.compact
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
          res._source.merge(id: res._id, type: res._type)
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

      def as_csv(opts = {})
        CSV.generate(opts) do |csv|
          to_a.each { |row| csv << row }
        end
      end

      def to_a
        result = []

        headers = response.results.first.try(:_source).try(:keys) || []
        result << ['id'] + headers

        response.results.each do |res|
          values = headers.map do |h|
            val = res._source[h]
            val.kind_of?(Array) ? val.join(';') : val
          end

          result << [res._id] + values
        end

        result
      end

      private

      attr_reader :view_context

      def search_params
        self.class.search_params.reject { |key, _| @ignored.include?(key) }
      end

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

          boolean_params.each do |name, opts|
            filters << {term: {name => true}} if @query[name] == 'true'
          end

          filters
        )
      end

      def facet_params
        @facet_params ||= search_params.
          select { |name, opts| opts && opts[:facet] }.
          map    { |name, opts| [name, opts[:facet]] }
      end

      def boolean_params
        @boolean_params ||= search_params.
          select { |name, opts| opts && opts[:boolean] }
      end

      def facets
        @facets ||= (
          f = {}

          if facet_params.any?
            result = f[:aggregations] = {}

            facet_params.each do |name, opts|
              field = opts.fetch(:field)

              result[field] = {
                terms: {
                  field: field.to_s,
                  all_terms: false,
                  size: opts[:size] || 10
                }
              }
            end
          end

          f
        )
      end

      class Navigator
        attr_reader :param, :title

        def initialize(search, query, title, param)
          @search = search
          @query  =  query
          @title  = title
          @param  = param
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

        def boolean?
          type == :boolean
        end

        def as_json(opts = nil)
          {
            query: @query,
            title: @title,
            param: @param,
            type: {keyword: keyword?, facet: facet?, boolean: boolean?}
          }
        end
      end

      class FacetNavigator < Navigator
        def initialize(search, query, title, param, data)
          super(search, query, title, param)

          @search = search
          @query  = query[param]
          @title  = title
          @total  = data['total']
          @terms  = data['buckets'].sort_by { |e| e['key'] }

          @terms.reverse! if [:parliament_period, :parliament_session, :vote_enacted].include? param
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
              active = @query == term['key'].to_s

              terms << build(term['key'], term['doc_count'], active)
            end
          end

          terms
        end

        private

        BOOLEAN_NAMES = {
          0 => 'Nei',
          1 => 'Ja'
        }

        def build(name, count, active)
          m = Hashie::Mash.new(
            name: BOOLEAN_NAMES[name] || name,
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
        def type
          :keyword
        end

        def value
          @search.query[param]
        end

        def as_json(opts = nil)
          super.merge(
            filter_url: @search.url(@param => '{query}', :page => nil),
            value: value
          )
        end
      end # KeywordNavigator

      class BooleanNavigator < Navigator
        def type
          :boolean
        end

        def value
          @search.query[param]
        end

        def filter_url
          @search.url(@param => 'true', :page => nil)
        end

        def clear_url
          @search.url(@param => nil, :page => nil)
        end

        def active?
          value == 'true'
        end

        def as_json(opts = nil)
          super.merge(
            filter_url: filter_url,
            clear_url: clear_url,
            value: value,
            active: active?
          )
        end
      end

    end # FacetSearch
  end # Search
end # Hdo
