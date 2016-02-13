class ApiController < ApplicationController
  include Roar::Rails::ControllerAdditions

  before_filter -> { expires_in 30.minutes, public: true }

  rescue_from StandardError do |exception|
    render json: exception_as_json(exception), status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: exception_as_json(exception), status: :not_found
  end

  respond_to :json, :hal

  private

  def exception_as_json(exception)
    res             = {message: exception.message}
    res[:backtrace] = exception.backtrace unless Rails.env.production?

    res
  end
end
