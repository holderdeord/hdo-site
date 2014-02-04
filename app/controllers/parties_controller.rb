class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @parties = Party.order(:name).all
  end

  def show
    @party           = Party.find(params[:id])
    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }

    @issue_groups = Issue.published.order(:title).grouped_by_accountability(@party)

    if AppConfig.show_propositions_feed
      propositions = @party.propositions.published.order('created_at DESC').first(5)
      @propositions_feed = Hdo::Utils::PropositionsFeed.new(propositions, title: "Siste forslag fra #{@party.name}")
    end
  end
end
