# -*- coding: utf-8 -*-
class Admin::IssuesController < AdminController
  before_filter :fetch_issue, only: [:show, :edit, :update]
  before_filter :fetch_sections, only: [:new, :create, :edit, :update]
  before_filter :authorize_edit, except: [:index, :show]

  def index
    issues = Issue.order('frontpage IS FALSE, title').includes(:tags, :editor, :last_updated_by)
    @issues_by_status = issues.group_by { |e| e.status }
    
    respond_to do |format|
      format.html
      format.json { render json: @issues_by_status.values.flatten }
    end
  end

  def new
    @issue = Issue.new(status: 'in_progress')
    render 'edit'
  end

  def create
    @issue = Issue.new(params[:issue])
    @issue.last_updated_by = current_user

    if @issue.save
      save_issue
    else
      render text: @issue.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  def show
    xhr_only {
      @parties             = Party.order(:name)
      @accountability      = @issue.accountability
      @promise_connections = @issue.promise_connections.includes(promise: :promisor)
      
      render layout: false
    }
  end

  def edit
  end

  def update
    logger.info "updating issue: #{params.to_json}"
    save_issue
  end

  def destroy
    @issue.destroy
    redirect_to admin_issues_url
  end

  def promises
    # xhr_only?
    json = params[:ids].split(',').map do |id|
      PromiseConnection.new(promise: Promise.find(id)).as_edit_view_json
    end

    render json: json
  end

  def propositions
    # xhr_only?
    json = params[:ids].split(',').map do |id|
      PropositionConnection.new(proposition: Proposition.find(id)).as_edit_view_json
    end

    render json: json
  end

  private

  def authorize_edit
    unless policy(@issue || Issue.new).edit?
      flash.alert = t('app.errors.unauthorized')
      redirect_to admin_root_path
    end
  end

  def fetch_issue
    @issue = Issue.find(params[:id])
  end

  def fetch_sections
    @sections = {
      intro: 'Intro',
      propositions: 'Forslag',
      promises: 'Løfter',
      positions: 'Posisjoner',
      party_comments: 'Partikommentarer'
    }
  end

  def save_issue
    ok = Hdo::IssueUpdater.new(@issue, params, current_user).update

    if ok
      PageCache.expire_issue(@issue)
      render json: { location: edit_admin_issue_path(@issue) }
    else
      render text: @issue.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

end
