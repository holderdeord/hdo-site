module Api
  class PromisesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_promise_url, id: 'id'),
        templated: true
      }
    end

    collection :to_a,
               embedded: true,
               as: :promises,
               extend: PromiseRepresenter


    def url_helper(opts)
      if issue = opts.delete(:issue)
        promises_api_issue_url(issue, opts)
      else
        api_promises_url(opts)
      end
    end

    def url_params_for(opts)
      params = {}

      params[:issue] = opts[:issue] if opts[:issue]

      params
    end
  end
end

