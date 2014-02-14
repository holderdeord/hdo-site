class PropositionDecorator < Draper::Decorator
  delegate :id, :to_param, :next, :previous

  def title
    str = model.simple_description || model.description
    str.blank? ? str : "#{UnicodeUtils.upcase str[0]}#{str[1..-1]}"
  end

  def datestamp
    ltime = model.vote_time.localtime
    if ltime > 1.week.ago
      "#{h.distance_of_time_in_words_to_now(ltime)} siden"
    else
      h.l ltime, format: :short_text
    end
  end

  def timestamp
    h.l model.vote_time.localtime, format: :text_time
  end

  def enacted?
    vote.enacted?
  end

  def body
    h.markdown(model.simple_body.strip).html_safe if model.simple_body
  end

  def original_body
    model.body.html_safe
  end

  def vote
    @vote ||= model.votes.find { |e| e.personal? } || model.votes.first
  end

  def proposers
    @proposers ||= sorted_proposers.map(&:name)
  end

  def supporters
    @supporters || (
      calculate_vote_groups
      @supporters
    )
  end

  def opposers
    @opposers || (
      calculate_vote_groups
      @opposers
    )
  end

  def absentees
    @absentees || (
      calculate_vote_groups
      @absentees
    )
  end

  def proposer_links
    @proposer_links ||= sorted_proposers.map { |e| h.link_to e.name, e }.to_sentence.html_safe
  end

  private

  def sorted_proposers
    @sorted_proposers ||= model.proposers.sort_by { |e| [e.class.name, e.name] }
  end

  def calculate_vote_groups
    @opposers   = []
    @supporters = []
    @absentees  = []

    s = vote.stats

    Party.all.each do |party|
      if s.party_for?(party)
        @supporters << party
      elsif s.party_against?(party)
        @opposers << party
      elsif s.party_absent?(party)
        @absentees << party
      end
    end

    @opposers.sort_by!(&:name)
    @supporters.sort_by!(&:name)
    @absentees.sort_by!(&:name)
  end
end
