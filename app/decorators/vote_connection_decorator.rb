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
    # TODO: i18n
    str = 'Avstemningen er <strong>'
    str << 'ikke ' unless matches?
    str << "i tråd med å #{issue.downcased_title}</strong>."

    str
  end

  def parties_for
    @parties_for ||= all_parties.select { |e| vote.stats.party_for?(e) }
  end

  def parties_against
    @parties_against ||= all_parties.select { |e| vote.stats.party_against?(e) }
  end

  def enacted_text
    # TODO: i18n
    str = "Forslaget ble <strong>"

    if enacted?
      str << "vedtatt"
    else
      str << "ikke vedtatt"
    end

    str << "</strong>."

    str
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
