module Api
  class PropositionRepresenter < BaseRepresenter
    property :auto_title, as: :title
    property :vote_time, as: :time
    property :body

    link :self do
      api_proposition_url represented
    end

    links :proposers do
      represented.proposers.map do |p|
        {
          title: p.name,
          href: p.kind_of?(Representative) ? api_representative_url(p) : api_party_url(p)
        }
      end
    end
  end
end
