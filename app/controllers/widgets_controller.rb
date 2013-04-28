class WidgetsController < ApplicationController
  before_filter { assert_feature(:widgets) }

  layout 'widgets'
  hdo_caches_page :load

  rescue_from ActiveRecord::RecordNotFound do
    render 'missing', status: 404 # TODO: nice error page
  end

  def issue
    issue = Issue.published.find(params[:id])

    if params[:id] !~ /^\d/
      redirect_to url_for(id: issue.to_param), status: :moved_permanently
    else
      @issue = issue.decorate
      @parties = Party.order(:name)
    end
  end

  def party
    @party  = Party.find(params[:id])
    @issues = issues_for(@party)
  end

  def representative
    @representative = Representative.find(params[:id])
    @issues = issues_for(@representative)
  end

  def topic
    promises = params[:promises] ? Promise.find(params[:promises].split(',')) : []
    issues   = params[:issues] ? Issue.published.find(params[:issues].split(',')) : []

    @issues   = IssueDecorator.decorate_collection(issues) if issues.any?
    @promises = promises
  end

  def load
  end

  private

  def issues_for(entity)
    issues = if params[:issues]
               Issue.published.find(params[:issues].split(','))
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
