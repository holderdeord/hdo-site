class Issue < ActiveRecord::Base
  belongs_to :committee
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :votes

  extend FriendlyId
  friendly_id :external_id, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def status_text
    status.gsub(/_/, ' ').capitalize
  end

  def last_update_text
    I18n.l last_update, format: :short
  end

  def url
    I18n.t("app.external.urls.issue") % external_id
  end

  def processed?
    status == I18n.t("app.issue.states.processed")
  end

end
