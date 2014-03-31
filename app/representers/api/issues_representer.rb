module Api
  module IssuesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_issues_url
    end

    links :issues do
      map { |e| {href: api_issue_url(e) } }
    end
  end
end