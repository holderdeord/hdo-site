module Api
  class DistrictRepresenter < BaseRepresenter

    link :self do
      api_district_url represented
    end

    property :name
    property :slug
  end
end
