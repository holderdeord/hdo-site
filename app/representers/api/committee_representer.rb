module Api
  class CommitteeRepresenter < BaseRepresenter
    property :name
    property :slug

    link :self do
      api_committee_url represented
    end

    links :representatives do
      represented.
        current_representatives.
        map { |rep| {href: api_representative_url(rep) } }
    end
  end
end
