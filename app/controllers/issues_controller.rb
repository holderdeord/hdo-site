# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :fetch_issue, except: [:index, :admin_info, :votes]
  hdo_caches_page :index, :votes, :show

  ALERT = "Dette innholdet vil ikke bli oppdatert."

  def index
    @groups = Issue.published.in_tag_groups
    @groups = @groups.sort_by { |t, _| t.name }

    @extra_alert_message = ALERT
  end

  def show
    if policy(@issue).show?
      @extra_alert_message = ALERT
      fresh_when @issue, public: can_cache?
      @issue = IssueDecorator.decorate(@issue)
    else
      redirect_to new_user_session_path
    end
  end

  def votes
    redirect_to action: 'show', status: :moved_permanently
  end

  def admin_info
    if user_signed_in?
      fetch_issue
      @issue = IssueDecorator.decorate(@issue)
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

end
