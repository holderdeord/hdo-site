module Api
  class RepresentativesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_representative_url, id: 'slug'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :representatives,
      as: :representatives,
      extend: RepresentativeRepresenter

    alias_method :url_helper, :api_representatives_url
  end
end
