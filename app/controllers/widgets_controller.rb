class WidgetsController < ApplicationController
  layout 'widgets'
  hdo_caches_page :load

  rescue_from ActiveRecord::RecordNotFound do
    render 'missing' # TODO: nice error page
  end

  def issues
    @issue = Issue.published.find(params[:id])
  end

  def representatives
    @representative = Representative.find(params[:id])
  end


  def load
  end
end
