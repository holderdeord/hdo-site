class RepresentativesController < ApplicationController
  caches_page :index, :index_by_district, :index_by_party, :index_by_name

  before_filter :fetch_representatives, :only => [:index, :index_by_district, :index_by_party, :index_by_name]

  def index
    respond_to do |format|
      format.html
      format.json { render json: Representative.order(:last_name) }
    end
  end

  def show
    @representative = Representative.find(params[:id])
    @issues         = Issue.published.order(:title).all.reject { |i| i.stats.score_for(@representative).nil? }

    respond_to do |format|
      format.html
      format.json { render json: @representative }
      format.xml  { render xml:  @representative }
    end
  end

  def index_by_district
    xhr_only {
      @by_district = @representatives.group_by { |e| e.district }
      render partial: 'index_by_district', locals: { groups: @by_district }
    }
  end

  def index_by_party
    xhr_only {
      @by_party = @representatives.group_by { |e| e.current_party }
      render partial: 'index_by_party', locals: { groups: @by_party }
    }
  end

  def index_by_name
    xhr_only {
      render partial: 'index_by_name', locals: { representatives: @representatives }
    }
  end

  private

  def fetch_representatives
    @representatives = Representative.includes(:district, :party_memberships => :party).order(:last_name)
  end
end
