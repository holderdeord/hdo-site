module Api
  class RootController < ApiController
    def index
      respond_with Object.new, represent_with: RootRepresenter
    end
  end
end

