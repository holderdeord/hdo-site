module QuestionsHelper
  def representative_options
    data = Representative.includes(party_memberships: :party).map do |r|
      ["#{r.full_name} (#{r.current_party.try(:name)})", r.slug]
    end

    options_for_select data, selected: params[:representative] || @question.representative.try(:slug)
  end

  def representative_map
    result = Hash.new { |hash, key| hash[key] = [] }
    Representative.includes(:district).order(:last_name).each do |rep|
      result[rep.district.slug] << rep.as_json(only: [:slug], methods: :name_with_party)
    end

    result
  end

  def question_issue_options
    data = Issue.search("*", per_page: 1000).map { |e| [e.title, e.id] }
    options_for_select data, selected: @question.issues.map(&:id)
  end
end