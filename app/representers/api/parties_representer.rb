module Api
  module PartiesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_parties_url
    end

    links :parties do
      to_a.map { |e| {href: api_party_url(e) } }
    end
  end
end