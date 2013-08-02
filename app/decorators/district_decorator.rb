class DistrictDecorator < Draper::Decorator
  delegate :name, :updated_at, :external_id

  def svg_path
    h.asset_path("district_logos/#{model.slug}.svg")
  end

  def attending_representatives
    @attending_representatives ||= model.representatives.attending.to_a
  end

  def representatives
    @representatives ||= model.representatives.to_a
  end
end
