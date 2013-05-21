class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  before_filter :fetch_issue, only: [:show, :positions]

  def index
    @parties = Party.order(:name).all
  end

  def show
    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }

    @issue_groups = Issue.published.order(:title).grouped_by_position(@party)
    @categories = Category.where(main: true).includes(children: :promises)
  end

  def positions
    @issue_groups = Issue.published.order(:title).grouped_by_accountability(@party)
  end

  private

  def fetch_issue
    @party = Party.find(params[:id])
  end

end
