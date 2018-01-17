module Api
  class GovernmentsRepresenter < BaseRepresenter
    link :self do
      api_governments_url
    end

    link :find do
      {
        href: templated_url(:api_government_url, id: 'slug'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :governments,
      as: :governments,
      extend: GovernmentRepresenter

  end
end
