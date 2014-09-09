module Api
  class PromisesController < ApiController

    def index
      respond_with Promise.by_date.page(params[:page] || 1).per(10)
    end

    def show
      respond_with Promise.find(params[:id])
    end

  end
end
