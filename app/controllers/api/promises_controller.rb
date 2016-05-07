module Api
  class PromisesController < ApiController

    def index
      rel = Promise.by_date
      rel = rel.random if params[:random]
      rel = rel.with_parliament_period(params[:parliament_period]) if params[:parliament_period]
      rel = rel.page(params[:page] || 1).per(10)
      rel = rel.where(id: params[:ids].split(',')) if params[:ids]

      respond_with rel, random: params[:random], parliament_period: params[:parliament_period]
    end

    def show
      respond_with Promise.find(params[:id])
    end

  end
end
