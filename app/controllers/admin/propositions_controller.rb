class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  DEFAULT_PER_PAGE = 20

  def index
    params[:parliament_session_name] ||= ParliamentSession.current.name

    @search_params = params.slice(:parliament_session_name, :q, :status)
    @propositions  = Hdo::Search::Searcher.new(params[:q], DEFAULT_PER_PAGE).propositions(params)
    @stats         = PropositionStats.new @propositions.facets
  end

  def edit
    @parliament_issues = @proposition.votes.includes(:parliament_issues).flat_map(&:parliament_issues).uniq
    @stats             = PropositionStats.from_session(@proposition.parliament_session_name)
  end

  def update
    update_issues || return

    if params[:save_publish] || params[:save_publish_next]
      params[:proposition][:status] = 'published'
    end

    if @proposition.update_attributes(normalize_blanks(params[:proposition]))
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

  class PropositionStats
    def self.from_session(session_name)
      Proposition.index.refresh
      search = Proposition.search(search_type: 'count') {
        query {
          filtered {
            query { string '*' }
            filter :term, parliament_session_name: session_name
          }
        }

        facet(:status) { terms :status }
      }

      new search.facets
    end

    def initialize(facets)
      @data = Hash.new(0)

      status_facet = facets['status']
      @data[:total] = status_facet['total']

      status_facet['terms'].each do |term|
        @data[term['term'].to_sym] = term['count']
      end
    end

    def published_percentage
      (published / total.to_f) * 100
    end

    def pending_percentage
      (pending / total.to_f) * 100
    end

    def published
      @data[:published]
    end

    def pending
      @data[:pending]
    end

    def total
      @data[:total]
    end
  end

end