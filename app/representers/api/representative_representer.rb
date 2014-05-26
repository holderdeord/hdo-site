module Api
  module RepresentativeRepresenter
    include Roar::Representer::JSON::HAL

    property :last_name
    property :first_name
    property :slug
    property :attending
    property :date_of_birth
    property :date_of_death
    property :twitter_id, as: :twitter

    link :self do
      api_representative_url represented
    end

    link :party do
      api_party_url latest_party
    end

    links :committees do
      current_committees.map { |e| {href: api_committee_url(e) } }
    end

    link :district do
      api_district_url district
    end

    link :image do
      {
        href: image_api_representative_url(represented) + '{?version}',
        templated: true,
        type: 'image/jpeg'
      }
    end

    link :twitter do
      {href: twitter_url, type: 'text/html'} if twitter_id
    end
  end
end