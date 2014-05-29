module Api
  module PartyRepresentativesRepresenter
    include Roar::Representer::JSON::HAL

    property :total_count, as: :total
    property :count

    link :self do |opts|
      if current_page == 1
        representatives_api_party_url party, url_params_from(opts)
      else
        representatives_api_party_url party, url_params_from(opts).merge(page: current_page)
      end
    end

    link :next do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: next_page)) if next_page
    end

    link :prev do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: prev_page)) if prev_page
    end

    link :last do |opts|
      representatives_api_party_url(party, url_params_from(opts).merge(page: total_pages)) if total_pages > 1
    end

    collection :to_a,
      embedded: true,
      name: :representatives,
      as: :representatives,
      extend: RepresentativeRepresenter

    def party
      @party ||= first.current_party
    end

    private

    def url_params_from(opts)
      params = {}
      params[:attending] = true if opts[:attending]

      params
    end
  end
end
