module Api
  class ParliamentIssueRepresenter < BaseRepresenter
    property :last_update
    property :summary
    property :description
    property :status_name

    link :self do
      api_parliament_issue_url represented
    end

    links :votes do
      represented.votes.map do |p|
        {
          title: p.subject,
          href: api_vote_url(p)
        }
      end
    end

  end
end
