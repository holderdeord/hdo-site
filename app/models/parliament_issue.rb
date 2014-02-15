class ParliamentIssue < ActiveRecord::Base
  extend FriendlyId

  include Hdo::Search::Index
  add_index_callbacks partial_update: false

  settings(SearchSettings.default) {
    mappings {
      indexes :summary,                 type: :string, analyzer: SearchSettings.default_analyzer
      indexes :description,             type: :string, analyzer: SearchSettings.default_analyzer
      indexes :status_name,             type: :string, index: :not_analyzed
      indexes :last_update,             type: :date,   include_in_all: false
      indexes :created_at,              type: :date,   include_in_all: false
      indexes :slug,                    type: :string, index: :not_analyzed
      indexes :parliament_session_name, type: :string, index: :not_analyzed
      indexes :issue_type_name,         type: :string, index: :not_analyzed
      indexes :document_group_name,     type: :string, index: :not_analyzed
      indexes :committee_name,          type: :string, index: :not_analyzed
      indexes :category_names,          type: :string, index: :not_analyzed
    }
  }

  attr_accessible :document_group, :issue_type, :status, :last_update,
                  :reference, :summary, :description, :committee, :categories

  belongs_to :committee
  has_many :propositions, through: :votes
  has_and_belongs_to_many :categories, uniq: true
  has_and_belongs_to_many :votes,      uniq: true

  validates :external_id, uniqueness: true

  friendly_id :external_id, use: :slugged

  scope :processed, -> { where("status = ?", I18n.t("app.parliament_issue.states.processed")) }
  scope :latest,    ->(limit) { order(:last_update).reverse_order.limit(limit) }

  def last_update_text
    I18n.l last_update, format: :short_text
  end

  def url
    I18n.t("app.external.urls.parliament_issue") % external_id
  end

  def parliament_session
    @parliament_session ||= ParliamentSession.for_date(last_update)
  end

  def parliament_session_name
    parliament_session.name
  end

  def committee_name
    committee.try(:name)
  end

  def category_names
    categories.map(&:human_name)
  end

  def status_name
    status.humanize
  end

  alias_method :status_text, :status_name

  def document_group_name
    document_group && document_group.humanize
  end

  def issue_type_name
    issue_type && issue_type.humanize
  end

  def processed?
    status == I18n.t("app.parliament_issue.states.processed")
  end

  def as_indexed_json(opts = nil)
    as_json methods: [
      :parliament_session_name,
      :committee_name,
      :category_names,
      :status_name,
      :document_group_name,
      :issue_type_name
    ]
  end

end
