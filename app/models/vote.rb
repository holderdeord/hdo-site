class Vote < ActiveRecord::Base
  belongs_to :issue
  validates_presence_of :issue

  has_many :vote_results, :dependent => :delete_all
  has_many :representatives, :through => :vote_results, :order => :last_name

  def time_text
    time.strftime("%Y-%m-%d")
  end

  def enacted_text
    enacted? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  def stats
    Stats.new for_count, against_count, missing_count
  end

  def minutes_url
    # FIXME: hardcoded session
    I18n.t("app.external.urls.minutes") % ['2011-2012', time.strftime("%y%m%d")]
  end

  class Stats
    def initialize(for_count, against_count, absent_count)
      @for_count     = for_count     || 0
      @against_count = against_count || 0
      @absent_count  = absent_count  || 0

      @total = @for_count + @against_count + @absent_count
      @total = 1 if @total.zero?
    end

    def for
      @for ||= percentage_of @for_count
    end

    def against
      @against ||= percentage_of @against_count
    end

    def missing
      @missing ||= percentage_of @absent_count
    end

    private

    def percentage_of(count)
      count * 100 / @total
    end
  end # Stats
end # Vote
