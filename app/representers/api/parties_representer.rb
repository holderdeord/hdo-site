module Api
  class PartiesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_party_url, id: 'slug'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :parties,
      as: :parties,
      extend: PartyRepresenter

    alias_method :url_helper, :api_parties_url
  end
end
