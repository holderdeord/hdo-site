module IssuesHelper
  def vote_options_for(vote, connection)
    if connection
      selected = connection.matches? ? 'for' : 'against'
    else
      selected = 'unrelated'
    end

    options_for_select(
      {
        t('app.for') => 'for',
        t('app.against') => 'against',
        t('app.unrelated') => 'unrelated'
      },
      selected
    )
  end

  def weight_options_for(connection)
    weight_options = {}

    VoteConnection::WEIGHTS.each do |weight|
      weight_options["%g" % weight] = weight
    end

    selected = (connection && connection.weight) || VoteConnection::DEFAULT_WEIGHT

    options_for_select weight_options, selected
  end

   def topic_options_for(issue)
    options_for_select( Topic.all.inject(Hash.new) { |options,topic| { topic.name => topic.id }.merge(options) }.sort_by { |name, id| name },
      issue.topic_ids)
  end

  def proposition_type_options_for(vote)
    prop_types = {}
    Vote::PROPOSITION_TYPES.each do |prop_type|
      prop_types[I18n.t("app.votes.proposition_types.#{prop_type}")] = prop_type
    end

    options_for_select prop_types, vote.proposition_type
  end
end
