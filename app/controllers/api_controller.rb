class ApiController < ApplicationController
  include Roar::Rails::ControllerAdditions

  before_filter -> { expires_in 1.minute, public: true }

  rescue_from StandardError do |exception|
    render json: {message: exception.message}, status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {message: exception.message}, status: :not_found
  end

  respond_to :json, :hal
end
