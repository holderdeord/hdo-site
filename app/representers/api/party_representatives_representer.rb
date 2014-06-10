#
# TODO: find a way to generalize this
#

module Api
  class PartyRepresentativesRepresenter < BaseRepresenter
    property :total_count, as: :total
    property :count

    link :self do |opts|
      if represented.current_page == 1
        representatives_api_party_url party, url_params_from(opts)
      else
        representatives_api_party_url party, url_params_from(opts).merge(page: represented.current_page)
      end
    end

    link :next do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: represented.next_page)) if represented.next_page
    end

    link :prev do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: represented.prev_page)) if represented.prev_page
    end

    link :last do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: represented.total_pages)) if represented.total_pages > 1
    end

    collection :to_a, embedded: true,
               as: lambda { |opts| opts[:attending] ? "attending_representatives" : "representatives" },
               extend: RepresentativeRepresenter

    def party
      @party ||= represented.first.current_party
    end

    private

    def url_params_from(opts)
      params = {}
      params[:attending] = true if opts[:attending]

      params
    end
  end
end
