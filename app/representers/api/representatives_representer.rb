module Api
  module RepresentativesRepresenter
    include Roar::Representer::JSON::HAL

    property :total_count

    link :self do
      if current_page == 1
        api_representatives_url
      else
        api_representatives_url page: current_page
      end
    end

    link :next do
      api_representatives_url(page: next_page) if next_page
    end

    link :prev do
      api_representatives_url(page: prev_page) if prev_page
    end

    link :find do
      {
        href: api_representative_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :representatives,
      as: :representatives,
      extend: RepresentativeRepresenter

  end
end