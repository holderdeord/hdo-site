class VoteConnection < ActiveRecord::Base
  WEIGHTS        = [0.0, 0.5, 1.0, 2.0, 4.0]
  DEFAULT_WEIGHT = 1.0

  belongs_to :vote
  belongs_to :issue

  attr_accessible :vote, :vote_id, :issue, :matches, :comment, :weight, :description

  validates_inclusion_of :weight, :in => WEIGHTS
  validates_presence_of  :vote,
                         :issue,
                         :weight


  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end
end
