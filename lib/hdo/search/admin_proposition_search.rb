module Hdo
  module Search
    class AdminPropositionSearch
      attr_reader :params, :next, :previous
      attr_accessor :model # for testing

      PER_PAGE = 25

      def initialize(params, current_id = nil)
        @params = params
        search
        set_next_and_prev_for(current_id) if current_id
      end

      def stats
        Hdo::Stats::PropositionCounts.new @response.response['facets']
      end

      def results
        @response.results
      end

      private

      def set_next_and_prev_for(id)
        ids = response_ids_from(@response)

        if ids.exclude?(id) && params[:flip]
          params[:page] = params[:flip].to_i
          @response = @response.page(params[:page])
          ids = response_ids_from(@response)
        end

        params.delete :flip

        ids.each_cons(2) do |left, right|
          @previous = left if right == id
          @next     = right if left == id
        end

        if @previous.nil? && ids.first == id && @response.prev_page
          params[:flip] = page = @response.prev_page
          @previous = response_ids_from(@response.page(page)).last
        end

        if @next.nil? && ids.last == id && @response.next_page
          params[:flip] = page = @response.next_page
          @next = response_ids_from(@response.page(page)).first
        end
      end

      def response_ids_from(response)
        response.results.map { |e| e._source.id }
      end

      def search
        q = {}

        query_string = params[:q].present? ? params[:q] : '*'

        if query_string == '*'
          q[:sort] = [{id: 'asc'}, {vote_time: 'asc'}]
        else
          q[:sort] = ['_score']
        end

        q[:query] = {
          filtered: {
            query:   {query_string: {query: query_string}},
            filter: {
              and: [
                { term: {parliament_session_name: params[:parliament_session_name] }}
              ]
            }
          }
        }

        q[:facets] = {
          status: {terms: {field: "status", size: 10, all_terms: false}}
        }

        if params[:status].present?
          q[:filter] = {term: {status: params[:status]}}
        end

        @response = model.search(q, size: params[:size]).page(params[:page] || 1).per(PER_PAGE)
      end

      def model
        @model ||= Proposition
      end
    end
  end
end
