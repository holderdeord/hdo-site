module Api
  class ParliamentIssueRepresenter < BaseRepresenter
    property :last_update
    property :summary
    property :description
    property :status_name

    link :self do
      api_parliament_issue_url represented
    end

  end
end
