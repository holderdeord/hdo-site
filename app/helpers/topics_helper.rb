module TopicsHelper
  def vote_options_for(vote)
    if @topic.vote_for?(vote.id)
      selected = 'for'
    elsif @topic.vote_against?(vote.id)
      selected = 'against'
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
end
