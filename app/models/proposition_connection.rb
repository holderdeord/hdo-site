# encoding: UTF-8

class PropositionConnection < ActiveRecord::Base
  belongs_to :issue
  belongs_to :proposition
  belongs_to :vote # optional

  attr_accessible :issue, :comment, :title, :proposition, :proposition_id,
                  :proposition_type, :vote_id

  PROPOSITION_TYPES = I18n.t('app.votes.proposition_types').except(:none).keys.map(&:to_s)
  validates_inclusion_of :proposition_type,
                         in: PROPOSITION_TYPES + [nil, '']


  validates_presence_of :issue, :proposition
  validates_uniqueness_of :proposition_id, scope: [:issue_id, :vote_id]

  validate :overrides_vote_if_proposition_has_several_votes

  def proposition_type_text
    I18n.t("app.votes.proposition_types.#{proposition_type}")
  end

  def title_with_fallback
    title || proposition.simple_description || proposition.description
  end

  def html_comment
    if comment || proposition.simple_body
      Hdo::Utils::Markdown.render(comment || proposition.simple_body)
    else
      proposition.plain_body.truncate(200)
    end
  end

  def vote
    super || proposition.votes.first
  end

  def multiple_votes?
    proposition && proposition.votes.size > 1
  end

  def as_edit_view_json
    {
      vote_time: I18n.l(vote.time.localtime, format: :text_time_precise),
      vote_id: vote_id,
      multiple_votes: multiple_votes?,
      votes: proposition.votes.sort_by(&:time).map { |v| v.as_json(only: [:id, :subject]).merge(selected: v.id == vote_id) },
      hdo_title: title.present? || proposition.simple_description.present?,
      title: title_with_fallback,
      proposition_id: proposition.id,
      id: id,
      connected: true,
      comment: comment,
      connection_title: title
    }
  end

  private

  def overrides_vote_if_proposition_has_several_votes
    if vote_id.nil? && multiple_votes?
      errors.add :proposition, I18n.t('app.errors.proposition_connections.must_override_vote')
    end
  end

end
