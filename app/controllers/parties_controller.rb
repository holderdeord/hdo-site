class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @parties = Party.order(:name).all
  end

  def show
    @party           = Party.find(params[:id])
    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }

    @parliament_period = ParliamentPeriod.named('2009-2013')
    @issue_groups      = Issue.published.order(:title).grouped_by_accountability(@party, @parliament_period)
  end
end
