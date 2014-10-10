module Api
  class IssueRepresenter < BaseRepresenter
    property :title
    property :description
    property :tag_list, as: :tags
    property :to_param, as: :slug

    property :published_at
    property :updated_at

    link :self do
      api_issue_url represented.id
    end

    link :promises do
      promises_api_issue_url represented.id
    end

    link :timeline do
      timeline_api_issue_url represented.id
    end
  end
end
