module Api
  module Hdo
    class BlogController < ApiController
      def index
        respond_with ::Hdo::Utils::BlogFetcher.last(10)
      end
    end
  end
end