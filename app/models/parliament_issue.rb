class ParliamentIssue < ActiveRecord::Base
  extend FriendlyId

  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire.settings(TireSettings.default) {
    mapping {
      indexes :summary, type: :string, analyzer: TireSettings.default_analyzer
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :status, type: :string
      indexes :last_update, type: :date, include_in_all: false
    }
  }

  attr_accessible :document_group, :issue_type, :status, :last_update,
                  :reference, :summary, :description, :committee, :categories

  belongs_to :committee
  has_and_belongs_to_many :categories, uniq: true
  has_and_belongs_to_many :votes,      uniq: true

  validates :external_id, uniqueness: true

  friendly_id :external_id, use: :slugged

  scope :processed, where("status = ?", I18n.t("app.parliament_issue.states.processed"))

  def status_text
    status.gsub(/_/, ' ').capitalize
  end

  def last_update_text
    I18n.l last_update, format: :short
  end

  def url
    I18n.t("app.external.urls.parliament_issue") % external_id
  end

  def processed?
    status == I18n.t("app.parliament_issue.states.processed")
  end

end
