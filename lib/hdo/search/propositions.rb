module Hdo
  module Search
    class Propositions
      include FacetSearch

      model Proposition
      default_sort :vote_time, 'desc'
      paginates_per 50

      search_param :parliament_session,  facet: {field: 'parliament_session_name', size: 100, title: 'Sesjon'}
      search_param :committee,           facet: {field: 'committee_names', size: 20, title: 'Komiteeer'}
      search_param :issue_type,          facet: {field: 'parliament_issue_type_names', size: 10, title: 'Sakstyper'}
      search_param :document_group,      facet: {field: 'parliament_issue_document_group_names', size: 10, title: 'Dokumentgrupper'}
      search_param :category,            facet: {field: 'category_names', size: 200, title: 'Kategorier'}
    end
  end
end
