class ApiController < ApplicationController
  include Roar::Rails::ControllerAdditions

  before_filter -> { expires_in 1.minute, public: true }

  respond_to :json, :hal
end
