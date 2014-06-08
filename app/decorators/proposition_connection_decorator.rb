# encoding: utf-8

class PropositionConnectionDecorator < Draper::Decorator
  alias_method :issue, :context

  delegate :vote,
           :title,
           :comment

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

  def all_parties
    @all_parties ||= Party.order(:name)
  end

end
