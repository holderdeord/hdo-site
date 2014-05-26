module Api
  module DistrictsRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_districts_url
    end

    link :find do
      {
        href: api_district_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :districts,
      as: :districts,
      extend: DistrictRepresenter

  end
end
