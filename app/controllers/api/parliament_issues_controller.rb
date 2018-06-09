module Api
  class ParliamentIssuesController < ApiController
    def index
      respond_with ParliamentIssue.order(:last_update).page(params[:page] || 1).per(10)
    end

    def show
      respond_with ParliamentIssue.find(params[:id])
    end
  end
end