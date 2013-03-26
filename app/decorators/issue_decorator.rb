class IssueDecorator < Draper::Decorator
  delegate :votes,
           :title,
           :to_json,
           :description,
           :vote_connections,
           :accountability,
           :published?,
           :cache_key,
           :party_comments,
           :tags,

           # move to decorator?
           :status_text,
           :editor_name,
           :last_updated_by_name,
           :stats,
           :downcased_title

  def explanation
    h.t('app.issues.explanation', count: votes.size, url: h.votes_issue_path(model)).html_safe
  end

  def published_at
    h.l model.published_at.localtime, format: :text
  end

  def updated_at
    h.l model.updated_at.localtime, format: :text
  end

  def time_since_updated
    h.distance_of_time_in_words_to_now model.updated_at.localtime
  end

  def position_groups
    grouped = Party.order(:name).group_by do |p|
      model.stats.key_for(model.stats.score_for(p))
    end

    [:for, :for_and_against, :against].map do |key|
      label = OpenStruct.new(:icon => "taxonomy-icons/issue_#{key}.png", :text => h.t("app.#{key}"))

      parties = grouped[key] || []
      [label, parties]
    end
  end

  def promises_by_party
    # {
    #   'A'    => { 'Partiprogram' => promises, 'Regjeringserklæring' => promises },
    #   'FrP'  => { 'Partiprogram' => promises },
    # }

    @promises_by_party ||= (
      result = {}

      model.promises.includes(:parties).each do |promise|
        promise.parties.each do |party|
          data = result[party] ||= {}
          (data[promise.source.downcase] ||= []) << promise
        end
      end

      result
    )
  end

  def party_groups
    government = Party.in_government.to_a
    opposition = Party.order(:name).to_a - government

    gov = IssuePartyDecorator.decorate_collection government, context: self
    opp = IssuePartyDecorator.decorate_collection opposition, context: self

    groups = []

    if government.any?
      groups << PartyGroup.new(h.t('app.parties.group.governing'), gov)
      groups << PartyGroup.new(h.t('app.parties.group.opposition'), opp)
    else
      # if no-one's in government, we only need a single group with no name.
      groups << PartyGroup.new('', opp)
    end

    groups
  end

  class PartyGroup < Struct.new(:name, :parties)
  end

  class IssuePartyDecorator < Draper::Decorator
    alias_method :issue, :context
    delegate :external_id, :image_with_fallback, :name

    def link(opts = {}, &blk)
      h.link_to h.party_path(model), opts, &blk
    end

    def logo(opts = {})
      h.image_tag model.logo.versions[:medium], opts.merge(alt: "#{model.name}s logo", width: '96', height: '96')
    end

    def position_logo
      key = issue.stats.key_for(score) # FIXME: take the party, not the score

      if key.nil? || key == :not_participated
        # could add taxonomy-icons/issue_not_participated.png
      else
        h.image_tag "taxonomy-icons/issue_#{key}.png"
      end
    end

    def position_caption
      key = issue.stats.key_for(score) # FIXME: take the party, not the score

      if key && key != :not_participated
        h.t("app.#{key}")
      end
    end

    def has_comment?
      !!comment
    end

    def comment
      issue.party_comments.where(:party_id => model.id).first
    end

    def promise_logo
      key = issue.accountability.key_for(model)

      # FIXME: missing icon for partially_kept
      if key == :partially_kept
        key = :kept
      end

      h.image_tag "taxonomy-icons/promise_#{key}.png"
    end

    def promise_caption
      key = issue.accountability.key_for(model)

      h.t("app.promises.scores.caption.#{key}")
    end

    def has_promises?
      promise_groups && promise_groups.values.any?
    end

    def promise_groups
      @promise_groups ||= issue.promises_by_party[model]
    end

    def score
      issue.stats.score_for(model)
    end

    def position_text
      [
        issue.stats.text_for(model, html: true),
        h.t('app.lang.infinitive_particle'),
        issue.downcased_title
      ].join(' ').html_safe
    end

    def accountability_text
      issue.accountability.text_for(model)
    end

    def votes
      votes = issue.vote_connections.sort_by { |e| e.vote.time }.reverse
      votes.map { |vc| PartyVote.new(model, vc) }.select(&:participated?)
    end
  end

  class PartyVote < Struct.new(:party, :vote_connection)
    def participated?
      stats.party_participated? party
    end

    def direction
      @direction ||= stats.party_for?(party) ? 'for' : 'against'
    end

    def title
      @title ||= (
        if vote_connection.title.blank?
          ''
        else
          title = vote_connection.title
          "#{I18n.t('app.lang.infinitive_particle')} #{UnicodeUtils.downcase title[0]}#{title[1..-1]}".strip
        end
      )
    end

    def time
      I18n.l vote_connection.vote.time, format: :short
    end

    def month_and_year
      I18n.l(vote_connection.vote.time, format: :month_year).capitalize
    end

    def anchor
      "vote-#{vote_connection.to_param}"
    end

    def label
      direction == 'for' ? 'For' : 'Mot'
    end

    def stats
      @stats ||= vote_connection.vote.stats
    end
  end
end
