module Admin::IssuesHelper
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
    topics = Topic.all.inject({}) { |options,topic| { topic.name => topic.id }.merge(options) }.sort_by { |name, id| name }

    options_for_select(topics , issue.topic_ids)
  end

  def proposition_type_options_for(vote)
    types  = I18n.t('app.votes.proposition_types').except(:none)
    sorted = types.invert.sort_by { |human_name, key| human_name }

    sorted.unshift [I18n.t!("app.votes.proposition_types.none"), nil]

    options_for_select sorted, vote.proposition_type
  end

  def connected_issues_for(vote)
    (vote.issues - [@issue]).first(3)
  end

end