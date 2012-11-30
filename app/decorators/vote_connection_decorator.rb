# encoding: utf-8

class VoteConnectionDecorator < Draper::Base
  decorates :vote_connection
  allows :vote, :title, :comment, :weight_text

  def proposition_type_text
    vote.proposition_type.blank? ? '' : I18n.t("app.votes.proposition_types.#{vote.proposition_type}")
  end

  def time_text
    I18n.l time, format: :text
  end

  def time
    vote.time
  end

  def matches_text
    if matches?
      I18n.t('app.votes.matches_issue.yes')
    else
      I18n.t('app.votes.matches_issue.no')
    end
  end

  def enacted_text
    if enacted?
      I18n.t('app.votes.enacted')
    else
      I18n.t('app.votes.enacted')
    end
  end

  def parties_for
    @parties_for ||= all_parties.select { |e| vote.stats.party_for?(e) }
  end

  def parties_against
    @parties_against ||= all_parties.select { |e| vote.stats.party_against?(e) }
  end

  private

  def enacted?
    vote.enacted?
  end

  def issue
    @issue ||= model.issue
  end

  def enacted?
    vote.enacted?
  end

  def matches?
    model.matches?
  end

  def all_parties
    @all_parties ||= Party.order(:name)
  end

end
