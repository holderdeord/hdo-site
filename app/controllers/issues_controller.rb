# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :fetch_issue, except: :index

  def index
    @groups = Issue.published.in_tag_groups
    @groups = @groups.sort_by { |t, _| t.name }
  end

  def show
    policy = policy(@issue)

    if policy.show?
      respond_to do |format|
        format.html {
          assign_previous_and_next_issues
          @issue = IssueDecorator.decorate(@issue)
        }

        format.json {
          render json: policy.view_stats? ? @issue.to_json_with_stats : @issue.to_json
        }
      end
    else
      redirect_to new_user_session_path
    end
  end

  def votes
    if policy(@issue).show?
      connections = @issue.vote_connections.includes(:vote).order("votes.time DESC")
      views       = VoteConnectionDecorator.decorate_collection(connections, context: @issue)

      # within each day, we want to order by time *ascending*
      grouped = views.group_by { |e| e.time.to_date }.values
      sorted  = grouped.flat_map { |vcs| vcs.sort_by { |e| e.time } }

      @issue_votes = sorted
      @all_parties = Party.order(:name)
      @issue       = IssueDecorator.decorate(@issue)
    else
      redirect_to new_user_session_path
    end
  end

  private

  def assign_previous_and_next_issues
    @previous_issue, @next_issue = @issue.previous_and_next(policy: policy(@issue))
  end

  def fetch_issue
    @issue = Issue.find(params[:id])
  end
end
