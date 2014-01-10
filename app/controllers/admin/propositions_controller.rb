class Admin::PropositionsController < AdminController
  before_filter :fetch_proposition, except: [:index]

  DEFAULT_PER_PAGE = 20

  def index
    @propositions = Proposition.order(:created_at).reverse_order
    @propositions = @propositions.where(status: params[:status]) if params[:status]
    @propositions = @propositions.paginate(page: params[:page], per_page: params[:per_page] || DEFAULT_PER_PAGE)

    @stats = PropositionStats.new
  end

  def edit

  end

  private

  def fetch_proposition
    @proposition = Proposition.find(params[:id])
  end

  class PropositionStats
    attr_reader :published, :pending

    def initialize
      @published, @pending = 0, 0

      propositions.select("count(*) as c, status").group(:status).each do |e|
        case e.status
        when 'published'
          @published += e.c.to_i
        when 'pending'
          @pending += e.c.to_i
        end
      end
    end

    def published_percentage
      (published / total.to_f) * 100
    end

    def pending_percentage
      (pending / total.to_f) * 100
    end

    def total
      propositions.size
    end

    private

    def propositions
      @propositions ||= Proposition.where('created_at > ?', ParliamentPeriod.current.try(:start_date) || 6.months.ago)
    end
  end

end