class DistrictsController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @districts = DistrictDecorator.decorate_collection District.includes(:representatives).all
  end

  def show
    district = District.includes(representatives: {party_memberships: :party}).find(params[:id])
    @district = district.decorate

    fresh_when @district, public: can_cache?
  end

end
