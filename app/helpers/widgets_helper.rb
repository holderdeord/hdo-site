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

  def link_for_promise(promise)
    opts = {}

    category = promise.categories.where(main: true).first
    category ||= promise.categories.first.parent

    party  = promise.parties.first
    period = promise.parliament_period

    opts[:party_slug] = party.slug
    opts[:period] = period.external_id if period
    opts[:category_id] = category.id if category && category.main?

    promises_path(opts)
  end

  def description_top?
    params[:desc].blank? || params[:desc] == 'top'
  end

  def description_bottom?
    params[:desc] == 'bottom'
  end
end
