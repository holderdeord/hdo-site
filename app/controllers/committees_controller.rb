class CommitteesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @committees = Committee.includes(:representatives).all
  end

  def show
    @committee = Committee.includes(:parliament_issues, representatives: {party_memberships: :party} ).find(params[:id])
    fresh_when @committee, public: can_cache?
  end

end
