module Api
  class RepresentativesRepresenter < BaseRepresenter
    property :total_count, as: :total
    property :count

    link :self do
      if represented.current_page == 1
        api_representatives_url
      else
        api_representatives_url page: represented.current_page
      end
    end

    link :next do
      api_representatives_url(page: represented.next_page) if represented.next_page
    end

    link :prev do
      api_representatives_url(page: represented.prev_page) if represented.prev_page
    end

    link :last do
      api_representatives_url(page: represented.total_pages) if represented.total_pages > 1
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
