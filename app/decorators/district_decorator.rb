class DistrictDecorator < Draper::Decorator
  delegate :name, :updated_at, :external_id

  def svg_path
    h.asset_path("district_logos/#{model.slug}.svg")
  end

  def attending_representatives
    @attending_representatives ||= sort_representatives(model.representatives.attending.to_a)
  end

  def representatives
    @representatives ||= sort_representatives(model.representatives.to_a)
  end

  private

  def sort_representatives(reps)
    reps.sort_by { |rep| [rep.latest_party.name, rep.last_name] }
  end
end
