class ParliamentIssue < ActiveRecord::Base
  extend FriendlyId

  include Hdo::Search::Index
  include Elasticsearch::Model::Callbacks

  settings(SearchSettings.default) {
    mappings {
      indexes :summary, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :description, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :status, type: :string
      indexes :last_update, type: :date, include_in_all: false
      indexes :created_at, type: :date, include_in_all: false
      indexes :slug, type: :string, index: :not_analyzed
    }
  }

  attr_accessible :document_group, :issue_type, :status, :last_update,
                  :reference, :summary, :description, :committee, :categories

  belongs_to :committee
  has_and_belongs_to_many :categories, uniq: true
  has_and_belongs_to_many :votes,      uniq: true

  validates :external_id, uniqueness: true

  friendly_id :external_id, use: :slugged

  scope :processed, -> { where("status = ?", I18n.t("app.parliament_issue.states.processed")) }
  scope :latest,    ->(limit) { order(:last_update).reverse_order.limit(limit) }

  def status_text
    status.gsub(/_/, ' ').capitalize
  end

  def last_update_text
    I18n.l last_update, format: :short_text
  end

  def url
    I18n.t("app.external.urls.parliament_issue") % external_id
  end

  def processed?
    status == I18n.t("app.parliament_issue.states.processed")
  end

end
