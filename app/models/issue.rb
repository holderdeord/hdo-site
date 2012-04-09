class Issue < ActiveRecord::Base
  belongs_to :committee
  has_and_belongs_to_many :topics
  has_many :votes

  def human_status
    status.gsub(/_/, ' ').capitalize
  end

  def human_last_update
    I18n.l last_update, format: :short
  end

  def url
    I18n.t("app.external.urls.issue") % external_id
  end

  def processed?
    status == I18n.t("app.issue.states.processed")
  end

end
