module Api
  module CommitteeRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_committee_url represented
    end

    links :representatives do
      current_representatives.map { |rep| {href: api_representative_url(rep) } }
    end

    property :name
    property :slug
  end
end