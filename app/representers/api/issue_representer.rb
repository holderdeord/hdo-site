module Api
  module IssueRepresenter
    include Roar::Representer::JSON::HAL

    property :title
    property :description
    property :tag_list, as: :tags
    property :to_param, as: :slug

    property :published_at
    property :updated_at

    link :self do
      api_issue_url id
    end
  end
end