module Api
  class ParliamentIssuesRepresenter < PagedRepresenter

    link :find do
      {
        href: templated_url(:api_parliament_issue_url, id: 'id'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :parliament_issues,
      as: :parliament_issues,
      extend: ParliamentIssueRepresenter

    alias_method :url_helper, :api_parliament_issues_url

  end
end
