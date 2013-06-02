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
      if stale?(issue, public: can_cache?)
        @issue = issue.decorate
        @parties = Party.order(:name)
      end
    end
  end

  def party
    @party  = Party.find(params[:id])
    @issues = issues_for(@party)
  end

  def representative
    assert_feature :representative_widget

    @representative = Representative.find(params[:id])
    @issues = issues_for(@representative)
  end

  def topic
    issues  = selected_issues
    @issues = IssueDecorator.decorate_collection(issues) if issues.any?

    @promise_groups = []
    params[:promises].each do |title, ids|
      @promise_groups << [title, Promise.includes(:parties).find(ids.split(','))]
    end
  end

  def promises
    promises = params[:promises] ? Promise.includes(:parties).find(params[:promises].split(',')) : []
    @promise_groups = promises.group_by { |e| e.parties.to_a }
  end

  def load
  end

  def configure
    user = current_user || authenticate_with_http_basic { |u, p| Hdo::BasicAuth.ok?(u, p) }
    if user
      issues = Issue.published

      example_party = Party.first
      example_promises = Promise.order('random()').first(5)

      @examples = []

      if issues.any?
        docs = Hdo::WidgetDocs.new
        @examples << docs.specific_issue(issues.first)
        @examples << docs.party_default(example_party)
        @examples << docs.party_count(example_party, 10)
        @examples << docs.party_issues(example_party, issues.order('random()').first(5))
        @examples << docs.promises(example_promises)
      end

      @issues = issues.order(:title)

      render layout: 'application'
    else
      request_http_basic_authentication('HDO Widgets')
    end
  end

  private

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
