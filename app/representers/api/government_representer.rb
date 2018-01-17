module Api
  class GovernmentRepresenter < BaseRepresenter
    property :name
    property :start_date
    property :end_date

    link :self do
      api_government_url represented
    end

    link :parties do
      parties_api_government_url represented
    end

    collection :parties,
      embedded: true,
      name: :parties,
      as: :parties,
      extend: PartyRepresenter

  end
end
