module Api
  module PartiesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_parties_url
    end

    link :next do
      api_parties_url(page: represented.next_page) if represented.next_page
    end

    link :find do
      {
        href: api_party_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    property :total_count

    collection :to_a,
      embedded: true,
      name: :parties,
      as: :parties,
      extend: PartyRepresenter

  end
end