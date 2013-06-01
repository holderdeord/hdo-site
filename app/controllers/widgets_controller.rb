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
      @issues = Issue.published.order(:title)

      @example_party = Party.first
      @example_promises = Promise.order('random()').first(5).map(&:id).join(',')

      @examples = {
        :script   => "<script src='#{widget_load_url}'></script>",
        :issue    => "<a class='hdo-issue-widget' href='#{root_url}' data-issue-id='#{@issues.first.try(:id)}'>Laster innhold fra Holder de ord</a>",
        :party    => "<a class='hdo-party-widget' href='#{root_url}' data-party-id='#{@example_party.try(:id)}'>Laster innhold fra Holder de ord</a>",
        :promises => "<a class='hdo-promises-widget' href='#{root_url}' data-promises='#{@example_promises}'>Laster innhold fra Holder de ord</a>",
      }

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
