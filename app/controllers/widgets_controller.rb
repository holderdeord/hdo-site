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
        @issue   = issue.decorate
        @period  = period_for(@issue)
        @parties = Party.order(:name)
      end
    end
  end

  def party
    @party  = Party.find(params[:id])
    @issues = issues_for(@party)
  end

  def topic
    issues  = selected_issues
    @issues = IssueDecorator.decorate_collection(issues) if issues.any?

    @promise_groups = []

    if params[:promises]
      params[:promises].each do |title, ids|
        @promise_groups << [title, Promise.includes(:promisor).find(ids.split(',')).sort_by { |p| p.parties.first.name }]
      end
    end
  end

  def promises
    promises = params[:promises] ? Promise.includes(:promisor).find(params[:promises].split(',')) : []
    periods = promises.map { |e| e.parliament_period }.uniq.sort_by { |e| e.start_date }

    @parliament_period_name = periods.map { |e| e.external_id }.join(', ')
    @promise_groups = promises.group_by { |e| e.parties.to_a }
  end

  def vote
    @vote = Vote.find(params[:id])

    opposers   = []
    supporters = []
    absentees  = []

    s = @vote.stats

    Party.all.each do |party|
      if s.party_for?(party)
        supporters << party
      elsif s.party_against?(party)
        opposers << party
      elsif s.party_absent?(party)
        absentees << party
      end
    end

    opposers.sort_by!(&:name)
    supporters.sort_by!(&:name)
    absentees.sort_by!(&:name)

    @position_groups = {
      'For'            => supporters,
      'Mot'            => opposers
    }
  end

  def load
  end

  def configure
    user = current_user || authenticate_with_http_basic { |u, p| Hdo::BasicAuth.ok?(u, p) }

    if user
      issues           = Issue.published
      example_party    = Party.order('random()').first
      example_promises = []
      period           = ParliamentPeriod.named('2009-2013')
      example_promises = period.promises.order('random()').first(5) if period
      example_vote     = Vote.find('1433776904e')

      @examples = []

      if issues.any?
        docs = Hdo::WidgetDocs.new

        @examples << docs.specific_issue(issues.first, period)
        @examples << docs.party_default(example_party)
        @examples << docs.party_count(example_party, 10)
        @examples << docs.party_issues(example_party, issues.order('random()').first(5))
        @examples << docs.promises(example_promises)
        @examples << docs.vote(example_vote)
      end

      @issues = issues.order(:title)

      render layout: 'application'
    else
      request_http_basic_authentication('HDO Widgets')
    end
  end

  private

  def selected_issues
    ids     = params[:issues] ? params[:issues].split(',').map(&:to_i) : []
    issues  = Issue.find(ids)

    ids.map { |id| issues.detect { |issue| issue.id == id } }
  end

  def issues_for(entity)
    issues = if params[:issues]
               Issue.published.find(params[:issues].split(','))
             else
               Issue.published.order(:updated_at).reverse_order
             end

    issues = issues.reject { |i| i.position_for(entity).nil? }

    if params[:issues]
      issues
    else
      issues.first((params[:count] || 5).to_i)
    end
  end

  def period_for(issue)
    period = params[:period] ? issue.periods.find { |e| e.name == params[:period] } : issue.periods.last

    if period.nil?
      raise ActiveRecord::RecordNotFound
    else
      period
    end
  end
end
