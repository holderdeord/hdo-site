module Api
  module PartyRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_party_url represented
    end

    property :name
    property :slug
  end
end