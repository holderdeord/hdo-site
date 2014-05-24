module Api
  module PartyRepresenter
    include Roar::Representer::JSON::HAL

    property :name
    property :slug

    link :self do
      api_party_url represented
    end

    link :logo do
      {
        href: logo_api_party_url(represented) + '{?version}',
        templated: true,
        type: 'image/png'
      }
    end
  end
end