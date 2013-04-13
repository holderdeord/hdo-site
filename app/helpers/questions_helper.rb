module QuestionsHelper
  def representative_options
    data = Representative.all.map { |r| ["#{r.full_name} (#{r.current_party.try(:name)})", r.slug] }
    options_for_select data, selected: @question.representative.try(:slug)
  end
end