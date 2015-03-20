module Api
  class PromisesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_promise_url, id: 'id'),
        templated: true
      }
    end

    links :widgets do
      result = [
        {
          title: 'all',
          href: widget_promises_url(represented.map(&:id).join(',')),
          type: 'text/html'
        }
      ]

      by_period = represented.group_by { |e| e.parliament_period }
      result += by_period.map do |period, promises|
        {
          title: period.name,
          href: widget_promises_url(promises.map(&:id).join(',')),
          type: 'text/html'
        }
      end

      result
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

