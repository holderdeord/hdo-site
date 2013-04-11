class PartiesController < ApplicationController
  hdo_caches_page :index

  def index
    @parties = Party.order(:name).all

    respond_to do |format|
      format.html
      format.json { render json: @parties }
      format.xml  { render xml:  @parties }
    end
  end

  def show
    @party  = Party.find(params[:id])
    @representatives = @party.current_representatives.sort_by { |e| e.image.to_s.include?("unknown") ? 1 : 0 }

    @issue_groups = Issue.published.order(:title).grouped_by_position(@party)
    @categories = Category.where(:main => true).includes(:children => :promises)

    respond_to do |format|
      format.html
      format.json { render json: @party }
      format.xml  { render xml:  @party }
    end
  end

  def positions
    @party = Party.find(params[:id])
    @issue_groups = Issue.published.order(:title).grouped_by_accountability(@party)
  end

end
