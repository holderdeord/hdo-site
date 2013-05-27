class PartiesController < ApplicationController
  hdo_caches_page :index, :show

  before_filter :fetch_issue, only: [:show, :positions]

  def index
    @parties = Party.order(:name).all
  end

  def show
    fetch_representatives

    @new_view = @false
    @issue_groups = Issue.published.order(:title).grouped_by_position(@party)
  end

  def positions
    fetch_representatives

    @new_view = true
    @issue_groups = Issue.published.order(:title).grouped_by_accountability(@party)

    render 'show'
  end

  private

  def fetch_issue
    @party = Party.find(params[:id])
  end

  def fetch_representatives
    @representatives = @party.current_representatives
    @representatives = @representatives.sort_by { |e| e.has_image? ? 0 : 1 }
  end

end
