class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  DEFAULT_PER_PAGE = 20

  def index
    params[:parliament_session_name] ||= ParliamentSession.current.name
    @search_params = params.slice(:parliament_session_name, :q, :status)

    @propositions = Hdo::Search::Searcher.new(params[:q], DEFAULT_PER_PAGE).propositions(params)
    @stats = PropositionStats.new @propositions
  end

  def edit
    @parliament_issues = @proposition.votes.includes(:parliament_issues).flat_map(&:parliament_issues)
  end

  def update
    raise NotImplementedError
    # remember: issue updates *must* go through IssueUpdater
  end

  private

  def fetch_proposition
    @proposition = Proposition.find(params[:id])
  end

  class PropositionStats
    def initialize(result)
      @data = Hash.new(0)

      status_facet = result.facets['status']
      @data[:total] = status_facet['total']

      status_facet['terms'].each do |term|
        @data[term['term'].to_sym] = term['count']
      end

      p result.facets
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