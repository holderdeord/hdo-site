module Hdo
  module Search
    class Promises
      include FacetSearch

      model Promise
      default_field :body

      search_param :parliament_period, facet: {field: 'parliament_period_name', size: 20,  title: 'Periode' }
      search_param :promisor,          facet: {field: 'promisor_name',          size: 20,  title: 'Parti / Regjering' }
      search_param :category,          facet: {field: 'category_names',         size: 200, title: 'Kategorier' }

      default_sort :promisor_name, 'asc'

      def url(params = {})
        view_context.promises_path @query.merge(params)
      end
    end
  end
end
