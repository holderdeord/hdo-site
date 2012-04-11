class Issue < ActiveRecord::Base
  belongs_to :committee
  has_and_belongs_to_many :topics
  has_many :votes

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
