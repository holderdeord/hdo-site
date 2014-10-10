module Api
  class VotesRepresenter < PagedRepresenter
    collection :to_a,
      embedded: true,
      name: :votes,
      as: :votes,
      extend: VoteRepresenter

    alias_method :url_helper, :api_votes_url
  end
end
