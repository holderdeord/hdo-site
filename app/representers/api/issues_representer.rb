module Api
  class IssuesRepresenter < BaseRepresenter
    property :total_count, as: :total
    property :count

    link :self do
      if represented.current_page == 1
        api_issues_url
      else
        api_issues_url page: represented.current_page
      end
    end

    link :next do
      api_issues_url(page: represented.next_page) if represented.next_page
    end

    link :prev do
      api_issues_url(page: represented.prev_page) if represented.prev_page
    end

    link :last do
      api_issues_url(page: represented.total_pages) if represented.total_pages > 1
    end

    link :find do
      {
        href: api_issue_url('...').sub('...', '{id}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :issues,
      as: :issues,
      extend: IssueRepresenter

  end
end
