module QuestionsHelper
  def representative_options
    reps = Representative.includes(:district, :party_memberships => :party).map do |r|
      party    = r.current_party.try(:external_id)
      district = r.district.name

      ["#{r.display_name} (#{party}, #{district})", r.id]
    end

    options_for_select reps
  end
end
