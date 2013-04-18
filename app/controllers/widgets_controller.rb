class WidgetsController < ApplicationController
  layout 'widgets'
  hdo_caches_page :load

  rescue_from ActiveRecord::RecordNotFound do
    render 'missing' # TODO: nice error page
  end

  def issues
    @issue   = Issue.published.find(params[:id]).decorate
    @parties = Party.order(:name)
  end

  def load
  end
end
