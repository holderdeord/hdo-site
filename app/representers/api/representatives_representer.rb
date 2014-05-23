module Api
  module RepresentativesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_representatives_url
    end

    link :next do
      api_representatives_url(page: represented.next_page) if represented.next_page
    end

    link :find do
      {
        href: api_representative_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    property :count

    collection :to_a,
      embedded: true,
      name: :representatives,
      as: :representatives,
      extend: RepresentativeRepresenter

  end
end