module QuestionsHelper
  def representative_options
    data = Representative.includes(party_memberships: :party).map do |r|
      ["#{r.full_name} (#{r.current_party.try(:name)})", r.slug]
    end

    options_for_select data, selected: params[:representative] || @question.representative.try(:slug)
  end

  def question_issue_options
    data = Issue.search("*", per_page: 1000).map { |e| [e.title, e.id] }
    options_for_select data, selected: @question.issues.map(&:id)
  end
end