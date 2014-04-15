class Admin::NewIssuesController < AdminController
  before_filter :fetch_issue, only: [:edit, :update]
  before_filter :fetch_sections, only: [:new, :create, :edit, :update]
  before_filter :authorize_edit

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

  def edit
  end

  def update
    logger.info "updating issue: #{params.to_json}"
    save_issue
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
      render json: { location: edit_next_admin_issue_path(@issue) }
    else
      render text: @issue.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

end
