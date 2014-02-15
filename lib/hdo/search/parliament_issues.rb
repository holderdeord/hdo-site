module Hdo
  module Search
    class ParliamentIssues
      include FacetSearch

      model ParliamentIssue
      default_sort :last_update, 'desc'
      paginates_per 25

      search_param :parliament_session,  facet: {field: 'parliament_session_name', size: 100, title: 'Sesjon'}
      search_param :status,              facet: {field: 'status_name', size: 20, title: 'Status'}
      search_param :committee,           facet: {field: 'committee_name', size: 20, title: 'Komité'}
      search_param :issue_type,          facet: {field: 'issue_type_name', size: 10, title: 'Sakstype'}
      search_param :document_group,      facet: {field: 'document_group_name', size: 10, title: 'Dokumentgruppe'}
      search_param :category,            facet: {field: 'category_names', size: 200, title: 'Kategorier'}

    end
  end
end