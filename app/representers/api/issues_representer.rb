module Api
  class IssuesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_issue_url, id: 'id'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :issues,
      as: :issues,
      extend: IssueRepresenter


    alias_method :url_helper, :api_issues_url

  end
end
