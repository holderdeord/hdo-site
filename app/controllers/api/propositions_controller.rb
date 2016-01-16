module Api
  class PropositionsController < ApiController

    def index
      rel = Proposition.page(params[:page] || 1).per(10)
      respond_with rel
    end

    def show
      respond_with Proposition.find(params[:id])
    end

  end
end
