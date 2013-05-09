module QuestionsHelper
  def data_representatives
    @representatives.map do |rep|
      { slug: rep.slug, name: rep.name_with_party, district: rep.district.slug }
    end
  end

  def question_issue_options
    data = Issue.search("*", per_page: 1000).map { |e| [e.title, e.id] }
    options_for_select data, selected: @question.issues.map(&:id)
  end
end