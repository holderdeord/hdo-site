module Api
  module RepresentativeRepresenter
    include Roar::Representer::JSON::HAL

    property :last_name
    property :first_name
    property :slug
    property :attending

    link :self do
      api_representative_url represented
    end

    link :party do
      api_party_url latest_party
    end

    links :committees do
      committees.map { |e| {href: api_committee_url(e) } }
    end
  end
end