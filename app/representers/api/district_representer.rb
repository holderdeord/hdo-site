module Api
  module DistrictRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_district_url represented
    end

    property :name
    property :slug

  end
end