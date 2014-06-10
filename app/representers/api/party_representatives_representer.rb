#
# TODO: find a way to generalize this
#

module Api
  class PartyRepresentativesRepresenter < PagedRepresenter

    collection :to_a, embedded: true,
               as: lambda { |opts| opts[:attending] ? :attending_representatives : :representatives },
               extend: RepresentativeRepresenter

    def party
      @party ||= represented.first.current_party
    end

    private

    def url_helper(opts)
      representatives_api_party_url(party, opts)
    end

    def url_params_for(opts)
      params = {}
      params[:attending] = true if opts[:attending]

      params
    end
  end
end
