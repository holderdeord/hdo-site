module Api
  class DistrictsController < ApiController

    def index
      respond_with District.order(:name)
    end

    def show
      respond_with District.find(params[:id])
    end

  end
end