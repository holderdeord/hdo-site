# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :fetch_issue

  def show
    if policy(@issue).show?
      assign_promises_by_party
      assign_party_groups
      assign_previous_and_next_issues

      @issue_explanation = t('app.issues.explanation',
        count: @issue.votes.size,
        url: votes_issue_path(@issue)
      ).html_safe

      respond_to do |format|
        format.html
        format.json { render json: @issue }
      end
    else
      redirect_to new_user_session_path
    end
  end

  def votes
    if policy(@issue).show?
      assign_party_groups

      connections = @issue.vote_connections
      @issue_votes = connections.map do |connection|
        Hdo::Views::IssueVote.new(connection, @party_groups)
      end

      @issue_votes = @issue_votes.sort_by { |e| e.time }.reverse
    else
      redirect_to new_user_session_path
    end
  end

  private

  def assign_previous_and_next_issues
    @previous_issue, @next_issue = @issue.previous_and_next(policy: policy(@issue))
  end

  def assign_party_groups
    @party_groups = Party.governing_groups
  end

  def assign_promises_by_party
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
