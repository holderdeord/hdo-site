module Api
  module Hdo
    class UsersController < ApiController
      def index
        respond_with User.active.order(:name)
      end
    end
  end
end