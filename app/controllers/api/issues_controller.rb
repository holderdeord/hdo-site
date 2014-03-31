class Api::IssuesController < ApiController
  def index
    respond_with Issue.published.order(:title)
  end

  def show
    respond_with Issue.published.find(params[:id])
  end
end
