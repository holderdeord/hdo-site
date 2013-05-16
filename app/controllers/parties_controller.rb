class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @parties = Party.order(:name).all
  end

  def show
    @party  = Party.find(params[:id])

    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }

    @issue_groups = Issue.published.order(:title).grouped_by_position(@party)
    @categories = Category.where(:main => true).includes(:children => :promises)
  end

  def positions
    @party = Party.find(params[:id])
    @issue_groups = Issue.published.order(:title).grouped_by_accountability(@party)
  end

end
