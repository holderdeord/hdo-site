class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  SEARCH_PARAMS = [:status, :parliament_session_name, :q, :page]

  def index
    session[:admin_proposition_search] = params.reverse_merge(parliament_session_name: ParliamentSession.current.name).slice(*SEARCH_PARAMS)

    @search       = Hdo::Search::AdminPropositionSearch.new(search_session)
    @stats        = @search.stats
    @propositions = @search.results
  end

  def edit
    @search            = Hdo::Search::AdminPropositionSearch.new(search_session, @proposition.id)
    @stats             = @search.stats
    @parliament_issues = @proposition.votes.includes(:parliament_issues).flat_map(&:parliament_issues).uniq
  end

  def update
    update_issues || return

    if params[:save_publish] || params[:save_publish_next]
      params[:proposition][:status] = 'published'
    end

    if @proposition.update_attributes(normalize_blanks(params[:proposition]))
      Proposition.__elasticsearch__.refresh_index!

      if params[:save_publish]
        redirect_to admin_propositions_path(status: 'published'), notice: t('app.updated.proposition')
      elsif params[:save_publish_next]
        path      = params[:next] ? edit_admin_proposition_path(params[:next]) : admin_propositions_path
        redirect_to path, notice: t('app.updated.proposition')
      elsif params[:save]
        redirect_to edit_admin_proposition_path(@proposition), notice: t('app.updated.proposition')
      end
    else
      flash.alert = @proposition.errors.full_messages.to_sentence
      redirect_to edit_admin_proposition_path(@proposition)
    end
  end

  private

  def fetch_proposition
    @proposition = Proposition.find(params[:id])
  end

  def update_issues
    issues = Array(params[:proposition].delete(:issues))
    issues.each do |issue_id|
      next if issue_id.empty?

      issue = Issue.find(issue_id)
      unless Hdo::IssueUpdater.for_proposition(@proposition, issue, current_user).update
        flash.alert = issue.errors.full_messages.to_sentence
        redirect_to(action: 'edit')
        return false
      end
    end

    true
  end

  def search_session
    session[:admin_proposition_search] || {parliament_session_name: ParliamentSession.current.name}
  end
end