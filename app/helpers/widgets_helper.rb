module WidgetsHelper
  def nrk?
    params[:nrk].present?
  end

  def slug_for_parties(parties)
    parties.size == 1 ? parties.first.slug : ''
  end

  def links_for_parties(parties)
    parties.map { |party| link_to party.name, party }.to_sentence
  end

  def description_top?
    params[:desc].blank? || params[:desc] == 'top'
  end

  def description_bottom?
    params[:desc] == 'bottom'
  end
end
