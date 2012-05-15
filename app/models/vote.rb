class Vote < ActiveRecord::Base
  has_and_belongs_to_many :issues
  validates_length_of :issues, :minimum => 1
  validates_presence_of :time

  has_many :propositions, :dependent => :delete_all
  has_many :vote_results, :dependent => :delete_all
  has_many :representatives, :through => :vote_results, :order => :last_name

  # should be not_personal
  scope :not_unanimous, where('for_count != 0 AND against_count != 0 AND absent_count != 0')

  def time_text
    time.strftime("%Y-%m-%d")
  end

  def enacted_text
    enacted? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  # TODO: should be "#personal?", though rare, votes can be unanimous and still have personal votes
  def unanimous?
    for_count == 0 && against_count == 0 && absent_count == 0
  end

  def stats
    Stats.new for_count, against_count, absent_count
  end

  def minutes_url
    # FIXME: hardcoded session
    I18n.t("app.external.urls.minutes") % ['2011-2012', time.strftime("%y%m%d")]
  end

  class Stats
    attr_reader :for_count, :against_count, :absent_count

    def initialize(for_count, against_count, absent_count)
      @for_count     = for_count     || 0
      @against_count = against_count || 0
      @absent_count  = absent_count  || 0
    end

    def as_json(opts = nil)
      {
        :for     => for_count,
        :against => against_count,
        :absent  => absent_count
      }
    end

    def vote_count
      @vote_count ||= for_count + against_count
    end

    def total_count
      @total_count ||= vote_count + absent_count
    end

    def for_percent
      @for_percent ||= percentage_of for_count, vote_count
    end

    def against_percent
      @against_percent ||= percentage_of against_count, vote_count
    end

    def absent_percent
      @absent_percent ||= percentage_of absent_count, total_count
    end

    def percentage_of(count, total)
      count * 100 / (total.zero? ? 1 : total)
    end
  end # Stats
end # Vote
