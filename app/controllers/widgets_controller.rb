class WidgetsController < ApplicationController
  before_filter { assert_feature(:widgets) }

  layout 'widgets'
  hdo_caches_page :load

  rescue_from ActiveRecord::RecordNotFound do
    render 'missing', status: 404 # TODO: nice error page
  end

  def issue
    @issue   = Issue.published.find(params[:id]).decorate
    @parties = Party.order(:name)
  end

  def party
    @party  = Party.find(params[:id])
    @issues = issues_for(@party)
  end

  def representative
    @representative = Representative.find(params[:id])
    @issues         = issues_for(@representative)
  end

  def load
  end

  private

  def issues_for(entity)
    issues = if params[:issues]
               Issue.published.where(slug: params[:issues].split(','))
             else
               Issue.published.vote_ordered
             end

    issues = issues.reject { |i| i.stats.score_for(entity).nil? }

    if params[:issues]
      issues
    else
      issues.first((params[:count] || 5).to_i)
    end
  end
end
