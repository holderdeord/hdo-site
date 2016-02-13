module Api
  module Hdo
    class UsersController < ApiController
      def index
        respond_with User.active.order(:name)
      end

      def show
        respond_with User.active.find(params[:id])
      end
    end
  end
end