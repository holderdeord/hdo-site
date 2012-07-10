class Vote < ActiveRecord::Base
  has_and_belongs_to_many :issues
  validates_length_of :issues, :minimum => 1
  validates_presence_of :time

  has_many :propositions, :dependent => :delete_all
  has_many :vote_results, :dependent => :delete_all
  has_many :representatives, :through => :vote_results, :order => :last_name

  has_many :vote_directions

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
    Hdo::Stats::VoteCounts.new self
  end

  def minutes_url
    # FIXME: hardcoded session
    I18n.t("app.external.urls.minutes") % ['2011-2012', time.strftime("%y%m%d")]
  end
end # Vote
