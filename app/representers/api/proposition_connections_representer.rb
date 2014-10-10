module Api
  class PropositionConnectionsRepresenter < PagedRepresenter
    collection :to_a,
      embedded: true,
      name: :timeline,
      as: :timeline,
      extend: PropositionConnectionRepresenter

    def url_helper(opts)
      timeline_api_issue_url(opts.delete(:issue), opts)
    end

    def url_params_for(opts)
      {}.merge(:issue => opts[:issue])
    end
  end
end
