module Api
  class PromiseRepresenter < BaseRepresenter
    property :body
    property :source
    property :promisor_name
    property :party_names
    property :parliament_period_name

    link :self do
      api_promise_url represented
    end

    link :parties do
      represented.parties.map do |p|
        { href: api_party_url(p) }
      end
    end
  end
end
