class QuestionDecorator < Draper::Decorator
  delegate :teaser,
           :has_approved_answer?

  def representative_avatar
    representative.image.versions[:avatar]
  end

  def representative_name
    representative.name
  end

  def party_logo
    party.logo
  end

  def party_name
    party.name
  end

  def district_name
    representative.district.name
  end

  def status_description
    if model.has_approved_answer?
      "Besvart for #{h.distance_of_time_in_words_to_now model.answer.created_at} siden"
    else
      "Venter på svar, stilt for #{h.distance_of_time_in_words_to_now model.created_at} siden"
    end
  end

  private

  def representative
    @representative ||= model.representative
  end

  def party
    @party ||= representative.party_at(model.created_at)
  end
end
