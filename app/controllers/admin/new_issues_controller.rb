class Admin::NewIssuesController < AdminController
  before_filter :fetch_issue, only: [:edit, :update]
  before_filter :authorize_edit

  def edit
    @sections = {
      intro: 'Intro',
      propositions: 'Forslag',
      promises: 'Løfter',
      positions: 'Posisjoner',
      party_comments: 'Partikommentarer'
    }
  end

  def update
    logger.info "updating issue: #{params.inspect}"
    update_ok = Hdo::IssueUpdater.new(@issue, params, current_user).update

    if update_ok
      head :ok
    else
      raise ""
    end
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

end
