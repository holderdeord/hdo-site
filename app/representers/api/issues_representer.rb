module Api
  module IssuesRepresenter
    include Roar::Representer::JSON::HAL

    property :total_count

    link :self do
      api_issues_url
    end

    link :next do
      api_issues_url(page: represented.next_page) if represented.next_page
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