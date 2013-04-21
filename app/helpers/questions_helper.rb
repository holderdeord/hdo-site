module QuestionsHelper
  def representative_options
    data = Representative.all.map { |r| ["#{r.full_name} (#{r.current_party.try(:name)})", r.slug] }
    options_for_select data, selected: @question.representative.try(:slug)
  end

  def question_issue_options
    data = Issue.published.map { |i| [i.title, i.id] }
    options_for_select data, selected: @question.issues.map(&:id)
  end
end