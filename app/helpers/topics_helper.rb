module TopicsHelper
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
end
