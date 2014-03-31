module Api
  module RepresentativeRepresenter
    include Roar::Representer::JSON::HAL

    property :last_name
    property :first_name
    property :slug

    link :self do
      api_representative_url represented
    end

    link :party do
      api_party_url represented.current_party
    end
  end
end