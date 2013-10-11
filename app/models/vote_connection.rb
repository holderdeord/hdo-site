# encoding: UTF-8

class VoteConnection < ActiveRecord::Base
  belongs_to :vote
  belongs_to :issue

  attr_accessible :vote, :vote_id, :issue, :matches, :comment, :title, :proposition_type

  PROPOSITION_TYPES = I18n.t('app.votes.proposition_types').except(:none).keys.map(&:to_s)
  validates_inclusion_of :proposition_type,
                         in: PROPOSITION_TYPES + [nil, '']


  validates_presence_of  :vote, :issue

  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  def proposition_type_text
    I18n.t("app.votes.proposition_types.#{proposition_type}")
  end

end
