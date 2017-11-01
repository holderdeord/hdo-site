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
  end
end
