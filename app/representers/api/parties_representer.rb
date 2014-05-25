module Api
  module PartiesRepresenter
    include Roar::Representer::JSON::HAL

    property :total_count

    link :self do
      if current_page == 1
        api_parties_url
      else
        api_parties_url page: current_page
      end
    end

    link :next do
      api_parties_url(page: next_page) if next_page
    end

    link :prev do
      api_parties_url(page: prev_page) if prev_page
    end

    link :find do
      {
        href: api_party_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :parties,
      as: :parties,
      extend: PartyRepresenter

  end
end