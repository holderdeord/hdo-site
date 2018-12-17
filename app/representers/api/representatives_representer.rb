module Api
  class RepresentativesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_representative_url, id: 'slug_or_external_id'),
        templated: true
      }
    end

    collection :to_a,
               embedded: true,
               name: :representatives,
               as: lambda { |opts| opts[:attending] ? :attending_representatives : :representatives },
               extend: RepresentativeRepresenter


    private

    def url_helper(opts)
      if party = opts.delete(:party)
        representatives_api_party_url(party, opts)
      else
        api_representatives_url(opts)
      end
    end

    def url_params_for(opts)
      params = {}

      params[:attending] = true if opts[:attending]
      params[:party]     = opts[:party] if opts[:party]

      params
    end

  end
end
