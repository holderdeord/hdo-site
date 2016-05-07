module Api
  class PromisesRepresenter < PagedRepresenter
    link :find do
      {
        href: templated_url(:api_promise_url, id: 'id'),
        templated: true
      }
    end

    link :filtered do |opts|
      params = url_params_for(opts)
      params.delete(:parliament_period)
      params.delete(:random)
      params.delete(:ids)

      {
        href: url_helper(params) + '{?parliament_period,random,ids}',
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
      elsif party = opts.delete(:party)
        promises_api_party_url(party, opts)
      else
        api_promises_url(opts)
      end
    end

    def url_params_for(opts)
      params = {}

      params[:issue]             = opts[:issue] if opts[:issue]
      params[:party]             = opts[:party] if opts[:party]
      params[:parliament_period] = opts[:parliament_period] if opts[:parliament_period]
      params[:random]            = opts[:random] if opts[:random]

      params
    end
  end
end

