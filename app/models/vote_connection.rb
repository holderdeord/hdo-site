class VoteConnection < ActiveRecord::Base
  WEIGHTS = [0, 0.5, 1, 2, 4]

  belongs_to :vote
  belongs_to :topic

  attr_accessible :vote, :vote_id, :topic, :matches, :comment, :weight, :description

  validates_presence_of :vote, :topic, :weight
  validates_inclusion_of :weight, :in => WEIGHTS

  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end
end
