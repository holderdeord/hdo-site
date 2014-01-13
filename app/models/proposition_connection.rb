# encoding: UTF-8

class PropositionConnection < ActiveRecord::Base
  belongs_to :issue
  belongs_to :proposition
  belongs_to :vote # optional

  attr_accessible :issue, :comment, :title, :proposition, :proposition_id, :proposition_type

  PROPOSITION_TYPES = I18n.t('app.votes.proposition_types').except(:none).keys.map(&:to_s)
  validates_inclusion_of :proposition_type,
                         in: PROPOSITION_TYPES + [nil, '']


  validates_presence_of :issue, :proposition
  validates_uniqueness_of :proposition_id, scope: :issue_id

  validate :overrides_vote_if_proposition_has_several_votes

  def proposition_type_text
    I18n.t("app.votes.proposition_types.#{proposition_type}")
  end

  def title_with_fallback
    title || proposition.simple_description || proposition.description
  end

  def comment_with_fallback
    comment || proposition.simple_body || proposition.plain_body.truncate(200)
  end

  def vote
    super || proposition.votes.first
  end

  private

  def overrides_vote_if_proposition_has_several_votes
    if vote_id.nil? && (proposition && proposition.votes.size > 1)
      errors.add :proposition, I18n.t('app.errors.proposition_connections.must_override_vote')
    end
  end

end
