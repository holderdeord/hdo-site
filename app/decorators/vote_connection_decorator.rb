# encoding: utf-8

class VoteConnectionDecorator < Draper::Decorator
  alias_method :issue, :context

  delegate :vote,
           :title,
           :comment,
           :weight_text

  def proposition_type_text
    model.proposition_type.blank? ? '' : I18n.t("app.votes.proposition_types.#{model.proposition_type}")
  end

  def time_text
    I18n.l time, format: :text
  end

  def time
    vote.time
  end

  def anchor
    "vote-#{model.to_param}"
  end

  def has_results?
    vote.vote_results.size > 0
  end

  def no_results_explanation
    if vote.inferred?
      I18n.t 'app.votes.non_personal.inferred'
    elsif vote.non_personal?
      I18n.t 'app.votes.non_personal.unknown'
    end
  end

  def matches_text
    if matches?
      I18n.t('app.votes.matches_issue.yes', issue_title: issue.downcased_title)
    else
      I18n.t('app.votes.matches_issue.no', issue_title: issue.downcased_title)
    end
  end

  def enacted_text
    if enacted?
      I18n.t('app.votes.enacted')
    else
      I18n.t('app.votes.not_enacted')
    end
  end

  def parties_for
    @parties_for ||= all_parties.select { |e| vote.stats.party_for?(e) }
  end

  def parties_against
    @parties_against ||= all_parties.select { |e| vote.stats.party_against?(e) }
  end

  def vote_result_groups
    @counts ||= (
      c = {
        :for => Hash.new,
        :against => Hash.new,
        :absent => Hash.new
      }

      c.each do |state, list|
        all_parties.each do |party|
          list[party] = Array.new
        end
      end

      vote.vote_results.includes(representative: {party_memberships: :party}).each do |result|
        party = result.representative.party_at(vote.time)
        c[result.state][party] << result.representative
      end

      c
    )
  end

  private

  def enacted?
    vote.enacted?
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
