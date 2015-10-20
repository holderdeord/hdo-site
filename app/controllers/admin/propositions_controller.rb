class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  SEARCH_PARAMS = [:parliament_session_name, :q, :page]

  def index
    session[:admin_proposition_search] = params.reverse_merge(parliament_session_name: ParliamentSession.current.name).slice(*SEARCH_PARAMS)

    @search       = Hdo::Search::AdminPropositionSearch.new(search_session)
    @propositions = @search.results
  end

  def edit
    @search               = Hdo::Search::AdminPropositionSearch.new(search_session, @proposition.id)
    @parliament_issues    = @proposition.parliament_issues
    @related_propositions = PropositionDecorator.decorate_collection(@proposition.related_propositions)
  end

  def update
    update_issues || return

    if @proposition.update_attributes(normalize_blanks(params[:proposition]))
      update_proposers
      Proposition.__elasticsearch__.refresh_index!

      if params[:save_next]
        path      = params[:next] ? edit_admin_proposition_path(params[:next]) : admin_propositions_path
        redirect_to path, notice: t('app.updated.proposition')
      else
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

  def update_proposers
    strings = Array(params.delete(:proposers))
    current_proposers = @proposition.proposers

    correct_proposers = strings.map do |str|
      klass, id = str.split('-')
      klass.constantize.find(id.to_i)
    end

    to_delete = current_proposers - correct_proposers
    to_add    = correct_proposers - current_proposers

    to_add.each { |p| @proposition.add_proposer(p) }
    to_delete.each { |p| @proposition.delete_proposer(p) }
  end

  def search_session
    session[:admin_proposition_search] || {parliament_session_name: ParliamentSession.current.name}
  end
end