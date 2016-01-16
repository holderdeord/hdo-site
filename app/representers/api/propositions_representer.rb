module Api
  class PropositionsRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_proposition_url, id: 'id'),
        templated: true
      }
    end

    collection :to_a,
               embedded: true,
               as: :propositions,
               extend: PropositionRepresenter


    def url_helper(opts)
      api_propositions_url(opts)
    end
  end
end

