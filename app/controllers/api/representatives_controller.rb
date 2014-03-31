class Api::RepresentativesController < ApiController
  def index
    respond_with Representative.order(:last_name).page(params[:page] || 1)
  end

  def show
    respond_with Representative.find(params[:id])
  end
end
