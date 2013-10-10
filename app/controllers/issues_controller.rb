# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :fetch_issue, except: [:index, :admin_info]

  hdo_caches_page :index, :show, :votes

  def index
    @groups = Issue.published.in_tag_groups
    @groups = @groups.sort_by { |t, _| t.name }
  end

  def show
    if policy(@issue).show?
      fresh_when @issue, public: can_cache?
      @issue = IssueDecorator.decorate(@issue)
      if @issue.valence_issue?
        fetch_issue_votes
        @all_parties = Party.order(:name)
      end
    else
      redirect_to new_user_session_path
    end
  end

  def next
    if policy(@issue).show?
      @issue = Hdo::NewIssue.new(@issue)
    else
      redirect_to new_user_session_path
    end
  end

  def votes
    return unless stale?(@issue, public: can_cache?)

    if policy(@issue).show?
      fetch_issue_votes
      @all_parties = Party.order(:name)
      @issue       = IssueDecorator.decorate(@issue)
    else
      redirect_to new_user_session_path
    end
  end

  def admin_info
    if user_signed_in?
      fetch_issue
      @issue = @issue.decorate

      render partial: 'admin_info'
    else
      head :ok
    end
  end

  private

  def fetch_issue
    @issue = Issue.find(params[:id])

    if params[:id] !~ /^\d/
      redirect_to url_for(id: @issue.to_param), status: :moved_permanently
    end
  end

  def fetch_issue_votes
    connections = @issue.vote_connections.includes(:vote).order("votes.time DESC")
    views       = VoteConnectionDecorator.decorate_collection(connections, context: @issue)

    # within each day, we want to order by time *ascending*
    grouped = views.group_by { |e| e.time.to_date }.values
    sorted  = grouped.flat_map { |vcs| vcs.sort_by { |e| e.time } }

    @issue_votes = sorted
  end
end
