module Api
  class RepresentativeRepresenter < BaseRepresenter
    property :last_name
    property :first_name
    property :slug
    property :attending
    property :date_of_birth
    property :date_of_death
    property :email
    property :twitter_id, as: :twitter
    property :wikidata_id, as: :wikidata

    link :self do
      api_representative_url represented
    end

    link :party do
      api_party_url represented.latest_party
    end

    links :committees do
      represented.current_committees.map { |e| {href: api_committee_url(e) } }
    end

    link :district do
      api_district_url represented.district
    end

    link :image do
      {
        href: image_api_representative_url(represented) + '{?version}',
        templated: true,
        type: 'image/jpeg'
      }
    end

    link :twitter do
      {
        href: represented.twitter_url,
        type: 'text/html'
      } if represented.twitter_id
    end

    link :wikidata do
      {
        href: represented.wikidata_url,
        type: 'application/json'
      } if represented.wikidata_url

    end
  end
end
