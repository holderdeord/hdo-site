module Api
  class PropositionConnectionRepresenter < BaseRepresenter
    property :time, exec_context: :decorator
    property :title_with_fallback, as: :title
    property :html_comment

    link :vote do
      api_vote_url represented.vote
    end

    def time
      represented.vote.time
    end
  end
end
