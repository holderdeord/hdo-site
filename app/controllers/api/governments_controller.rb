module Api
  class GovernmentsController < ApiController
    before_filter :fetch_government, except: :index

    def index
      respond_with Government.order(:start_date)
    end

    def show
      respond_with @government
    end

    def parties
      rel = @government.parties;
      rel = rel.page(params[:page] || 1)

      respond_with rel, represent_with: PartiesRepresenter, government: @government
    end

    private

    def fetch_government
      @government = Government.find(params[:id])
    end

  end
end