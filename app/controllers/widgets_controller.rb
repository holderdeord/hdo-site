class WidgetsController < ApplicationController
  before_filter { assert_feature(:widgets) }

  layout 'widgets'
  hdo_caches_page :load, :issue, :party, :representative, :topic, :promises

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
    promises = selected_promises
    issues   = selected_issues

    @issues   = IssueDecorator.decorate_collection(issues) if issues.any?
    @promises = promises
  end

  def promises
    @promise_groups = selected_promises.group_by { |e| e.parties.to_a }
  end

  def load
  end

  private

  def selected_promises
    params[:promises] ? Promise.includes(:parties).find(params[:promises].split(',')) : []
  end

  def selected_issues
    params[:issues] ? Issue.published.find(params[:issues].split(',')) : []
  end

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
