class ApiController < ApplicationController
  include Roar::Rails::ControllerAdditions

  respond_to :json, :hal
end
