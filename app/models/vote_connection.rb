class VoteConnection < ActiveRecord::Base
  belongs_to :vote
  belongs_to :topic

  attr_accessible :vote, :vote_id, :topic, :matches, :comment, :weight

  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end
end
