module Api
  class VotesController < ApiController
    before_filter :fetch_vote, except: :index

    def index
      respond_with Vote.
        order(:time).
        reverse_order.
        page(params[:page] || 1)
    end

    def show
      respond_with @vote
    end

    private

    def fetch_vote
      @vote = Vote.find(params[:id])
    end
  end
end
