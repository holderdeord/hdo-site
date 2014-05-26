module Api
  module IssuesRepresenter
    include Roar::Representer::JSON::HAL

    property :total_count, as: :total
    property :count

    link :self do
      if current_page == 1
        api_issues_url
      else
        api_issues_url page: current_page
      end
    end

    link :next do
      api_issues_url(page: next_page) if next_page
    end

    link :prev do
      api_issues_url(page: prev_page) if prev_page
    end

    link :last do
      api_issues_url(page: total_pages) if total_pages > 1
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