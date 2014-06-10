module Api
  class PartiesRepresenter < BaseRepresenter
    property :total_count, as: :total
    property :count

    link :self do
      if represented.current_page == 1
        api_parties_url
      else
        api_parties_url page: represented.current_page
      end
    end

    link :next do
      api_parties_url(page: represented.next_page) if represented.next_page
    end

    link :prev do
      api_parties_url(page: represented.prev_page) if represented.prev_page
    end

    link :last do
      api_parties_url(page: represented.total_pages) if represented.total_pages > 1
    end

    link :find do
      {
        href: api_party_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :parties,
      as: :parties,
      extend: PartyRepresenter

  end
end
