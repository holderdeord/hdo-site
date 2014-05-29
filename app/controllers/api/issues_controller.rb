module Api
  class IssuesController < ApiController
    def index
      respond_with Issue.
                    published.
                    order(:title).
                    page(params[:page] || 1).per(10)
    end

    def show
      respond_with Issue.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {message: "could not find issue with id=#{params[:id]}"}, status: :not_found
    end
  end
end
