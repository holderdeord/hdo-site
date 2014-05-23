module Api
  class PartiesController < ApiController
    def index
      respond_with Party.order(:name).page(params[:page] || 1)
    end

    def show
      respond_with Party.find(params[:id])
    end
  end
end
