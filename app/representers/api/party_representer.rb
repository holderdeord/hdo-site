module Api
  class PartyRepresenter < BaseRepresenter

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

    link :widget do
      {
        href: widget_party_url(represented),
        type: 'text/html'
      }
    end

    link :logo do
      {
        href: templated_url(:logo_api_party_url, represented, version: 'version'),
        templated: true,
        type: 'image/png'
      }
    end

    link :promises do
      promises_api_party_url represented
    end
  end
end
