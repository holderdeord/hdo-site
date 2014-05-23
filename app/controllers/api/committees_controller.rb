class Api::CommitteesController < ApiController
  def index
    respond_with Committee.order(:name)
  end

  def show
    respond_with Committee.find(params[:id])
  end
end
