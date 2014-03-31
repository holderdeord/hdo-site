class Root; end

module Api
  class RootController < ApiController
    def index
      respond_with Root.new
    end
  end
end

