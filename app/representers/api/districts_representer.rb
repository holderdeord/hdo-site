module Api
  class DistrictsRepresenter < BaseRepresenter
    link :self do
      api_districts_url
    end

    link :find do
      {
        href: templated_url(:api_district_url, id: 'slug'),
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
