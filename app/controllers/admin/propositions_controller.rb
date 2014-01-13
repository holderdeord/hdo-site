class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  DEFAULT_PER_PAGE = 20

  def index
    params[:parliament_session_name] ||= ParliamentSession.current.name

    @search_params = params.slice(:parliament_session_name, :q, :status)
    @propositions  = Hdo::Search::Searcher.new(params[:q], DEFAULT_PER_PAGE).propositions(params)
    @stats         = Hdo::Stats::PropositionCounts.new @propositions.facets
  end

  def edit
    @parliament_issues = @proposition.votes.includes(:parliament_issues).flat_map(&:parliament_issues).uniq
    @stats             = Hdo::Stats::PropositionCounts.from_session(@proposition.parliament_session_name)
  end

  def update
    update_issues || return

    if params[:save_publish] || params[:save_publish_next]
      params[:proposition][:status] = 'published'
    end

    if @proposition.update_attributes(normalize_blanks(params[:proposition]))
      Proposition.index.refresh

      if params[:save_publish]
        redirect_to admin_propositions_path(status: 'published'), notice: t('app.updated.proposition')
      elsif params[:save_publish_next]
        next_prop = @proposition.next
        path      = next_prop ? edit_admin_proposition_path(next_prop) : admin_propositions_path
        redirect_to path, notice: t('app.updated.proposition')
      elsif params[:save]
        edit && render(action: 'edit')
      end
    else
      edit && render(action: 'edit')
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
        edit && render(action: 'edit')
        return false
      end
    end

    true
  end
end