module Api
  module PartyRepresenter
    include Roar::Representer::JSON::HAL

    property :name
    property :slug

    link :self do
      api_party_url represented
    end
  end
end