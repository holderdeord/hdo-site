module Api
  module IssueRepresenter
    include Roar::Representer::JSON::HAL

    link :self do
      api_issue_url represented.id
    end

    property :title
    property :description
    property :tag_list, as: :tags
  end
end