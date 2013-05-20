class RepresentativesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @representatives = Representative.includes(:district, party_memberships: :party).order(:last_name)
  end

  def show
    @representative = Representative.find(params[:id])
    @questions      = @representative.questions.approved
    @party          = @representative.latest_party
    @issue_groups   = Issue.published.order(:title).grouped_by_position(@representative)
  end
end
