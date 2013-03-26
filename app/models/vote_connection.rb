# encoding: UTF-8

class VoteConnection < ActiveRecord::Base
  WEIGHTS        = [0.0, 0.5, 1.0, 2.0]
  DEFAULT_WEIGHT = 1.0

  belongs_to :vote
  belongs_to :issue

  attr_accessible :vote, :vote_id, :issue, :matches, :comment, :weight, :title, :proposition_type

  PROPOSITION_TYPES = I18n.t('app.votes.proposition_types').except(:none).keys.map(&:to_s)
  validates_inclusion_of :proposition_type,
                         in: PROPOSITION_TYPES + [nil, '']


  validates_inclusion_of :weight, :in => WEIGHTS
  validates_presence_of  :vote,
                         :issue,
                         :weight

  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  def proposition_type_text
    I18n.t("app.votes.proposition_types.#{proposition_type}")
  end

  def weight_text
    case weight
    when 0
      'uten formell betydning'
    when 0.5
      'noe viktig'
    when 1
      'viktig'
    when 2
      'svært viktig'
    else
      raise "unknown weight: #{weight}"
    end
  end

end
