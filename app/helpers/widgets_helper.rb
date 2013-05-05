module WidgetsHelper
  def nrk?
    params[:nrk].present?
  end

  def slug_for_parties(parties)
    parties.size == 1 ? parties.first.slug : ''
  end
end
