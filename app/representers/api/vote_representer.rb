module Api
  class VoteRepresenter < BaseRepresenter
    property :subject
    property :time
    property :external_id

    property :enacted
    property :stats, as: :counts

    link :self do
      api_vote_url represented
    end

    link :parliament_issues do
      represented.parliament_issues.map { |e| {href: api_parliament_issue_url(e) } }
    end

  end
end
