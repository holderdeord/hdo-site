module Api
  module RepresentativesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_representatives_url
    end

    links :representatives do
      map { |e| {href: api_representative_url(e) } }
    end
  end
end