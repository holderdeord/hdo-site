module Api
  class PromiseRepresenter < BaseRepresenter
    property :body
    property :source
    property :promisor_name
    property :party_names
    property :parliament_period_name
    property :category_names

    link :self do
      api_promise_url represented
    end

    links :parties do
      represented.parties.map do |p|
        {
          title: p.name,
          slug: p.slug,
          href: api_party_url(p)
        }
      end
    end

    link :widget do
      {
        href: widget_promises_url(represented),
        type: 'text/html'
      }
    end

  end
end
