class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @parties = Party.order(:name).all
  end

  def show
    @party           = Party.find(params[:id])
    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }

    @propositions_feed = Hdo::Utils::PropositionsFeed.for_model(
      @party,
      see_all: true,
      title: "Siste forslag fra #{@party.name}"
    )
  end
end
