# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :fetch_issue

  def show
    policy = policy(@issue)

    if policy.show?
      assign_promises_by_party
      assign_previous_and_next_issues

      @issue_explanation = t('app.issues.explanation',
        count: @issue.votes.size,
        url: votes_issue_path(@issue)
      ).html_safe

      respond_to do |format|
        format.html
        format.json {
          render json: policy.view_stats? ? @issue.to_json_with_stats : @issue
        }
      end
    else
      redirect_to new_user_session_path
    end
  end

  def votes
    if policy(@issue).show?
      connections = @issue.vote_connections.includes(:vote).order("votes.time DESC")
      views       = VoteConnectionDecorator.decorate(connections)

      # within each day, we want to order by time *ascending*
      grouped = views.group_by { |e| e.time.to_date }.values
      sorted  = grouped.flat_map { |vcs| vcs.sort_by { |e| e.time } }

      @issue_votes = sorted
    else
      redirect_to new_user_session_path
    end
  end

  private

  def assign_previous_and_next_issues
    @previous_issue, @next_issue = @issue.previous_and_next(policy: policy(@issue))
  end

  def assign_promises_by_party
    # TODO: move to IssueDecorator?

    # {
    #   'A'    => { 'I partiprogrammet har...' => promises, 'I regjeringserklæring har...' => promises },
    #   'FrP'  => { 'I partiprogrammet har...' => promises },
    # }

    @promises_by_party = {}

    @issue.promises.includes(:parties).each do |promise|
      promise.parties.each do |party|
        data = @promises_by_party[party] ||= {}
        (data[promise.source_header] ||= []) << promise
      end
    end
  end

  def fetch_issue
    @issue = Issue.find(params[:id])
  end
end
