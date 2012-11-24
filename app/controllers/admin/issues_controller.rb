class Admin::IssuesController < AdminController
  before_filter :ensure_editable, except: :index
  before_filter :fetch_issue, only: [:edit, :update, :destroy, :votes_search]
  before_filter :add_abilities

  helper_method :edit_steps

  def index
    issues = Issue.order(:title).includes(:topics, :editor, :last_updated_by)
    @issues_by_status = issues.group_by { |e| e.status }

    respond_to do |format|
      format.html
      format.json { render json: @issues_by_status.values.flatten }
    end
  end

  def new
    @issue = Issue.new
    fetch_categories

    edit_steps.first!

    respond_to do |format|
      format.html
      format.json { render json: @issue }
    end
  end

  def edit
    if edit_steps.from_param
      assign_disable_buttons
      assign_issue_steps

      step = edit_steps.from_param!
      send "edit_#{step}"
    else
      redirect_to edit_step_admin_issue_path(@issue.id, :step => edit_steps.first)
    end
  end

  def create
    @issue = Issue.new(params[:issue])
    @issue.last_updated_by = current_user

    if @issue.save
      if edit_steps.finish?
        redirect_to @issue
      else
        redirect_to edit_step_admin_issue_path(@issue.id, :step => edit_steps.after)
      end
    else
      logger.warn "failed to create issue: #{@issue.inspect}: #{@issue.errors.full_messages}"

      flash.alert = @issue.errors.full_messages.to_sentence
      fetch_categories

      render action: :new
    end
  end

  def update
    update_ok = Hdo::IssueUpdater.new(@issue, params[:issue], params[:votes], params[:promises], current_user).update

    if update_ok
      edit_steps.next!

      if edit_steps.finish?
        session.delete :issue_step
        redirect_to @issue
      else
        redirect_to edit_step_admin_issue_path(@issue.id, step: edit_steps.current)
      end
    else
      logger.warn "failed to update issue: #{@issue.inspect}: #{@issue.errors.full_messages}"

      flash.alert = @issue.errors.full_messages.to_sentence
      redirect_to edit_step_admin_issue_path(@issue.id, :step => edit_steps.current)
    end
  end

  def destroy
    @issue.destroy

    respond_to do |format|
      format.html { redirect_to admin_issues_url }
      format.json { head :no_content }
    end
  end

  def votes_search
    votes = Vote.admin_search(
      params[:filter],
      params[:keyword],
      @issue.categories
    )

    # remove already connected votes
    votes -= @issue.vote_connections.map { |e| e.vote }

    # TODO: cleanup
    by_issue_type = Hash.new { |hash, issue_type| hash[issue_type] = Set.new }
    votes.each do |vote|
      vote.parliament_issues.each do |issue|
        by_issue_type[issue.issue_type] << vote
      end
    end

    render partial: 'votes_search_result', locals: { votes_by_issue_type: by_issue_type }
  end

  private

  def edit_categories
    fetch_categories
  end

  def edit_promises
    @promises_by_party = @issue.categories.includes(:promises => [:promise_connections, :parties]).map(&:promises).compact.
                                           flatten.uniq.group_by { |e| e.short_party_names }
  end

  def edit_votes
    @votes_and_connections = @issue.vote_connections.map { |e| [e.vote, e] }
  end

  def edit_topics
    @topics = Topic.all
  end

  def edit_steps
    @edit_steps ||= Hdo::IssueEditSteps.new(params, session)
  end

  def ensure_editable
    unless AppConfig.issue_editing_enabled
      flash.alert = t('app.issues.edit.disabled')
      redirect_to root_path
    end
  end

  def assign_issue_steps
    @issue_steps = Hdo::IssueEditSteps::STEPS
  end

  def assign_disable_buttons
    @disable_next = edit_steps.last?(params[:step]) or @issue && @issue.new_record?
    @disable_prev = edit_steps.first?(params[:step])
  end

  def fetch_categories
    @categories = Category.column_groups 4
  end

  def fetch_issue
    @issue = Issue.find(params[:id])
  end

  def add_abilities
    abilities << Issue
  end
end
