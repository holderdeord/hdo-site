module Api
  module CommitteesRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_committees_url
    end

    link :find do
      {
        href: api_committee_url('...').sub('...', '{slug}'),
        templated: true
      }
    end

    collection :to_a,
      embedded: true,
      name: :committees,
      as: :committees,
      extend: CommitteeRepresenter

  end
end