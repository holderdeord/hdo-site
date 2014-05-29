module Api
  module PartyRepresenter
    include Roar::Representer::JSON::HAL

    property :name
    property :slug

    link :self do
      api_party_url represented
    end

    link :representatives do
      representatives_api_party_url represented
    end

    link :attending_representatives do
      representatives_api_party_url represented, attending: true
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