class Vote < ActiveRecord::Base
  include Hdo::ModelHelpers::HasStatsCache
  extend FriendlyId

  attr_accessible :for_count, :against_count, :absent_count,
                  :enacted, :personal, :subject, :time

  has_and_belongs_to_many :issues
  validates_length_of :issues, :minimum => 1
  validates_presence_of :time

  has_many :propositions, :dependent => :destroy
  has_many :vote_results, :dependent     => :destroy,
                          :before_add    => :clear_stats_cache,
                          :before_remove => :clear_stats_cache

  has_many :representatives, :through => :vote_results, :order => :last_name
  has_many :vote_connections

  friendly_id :external_id, :use => :slugged

  scope :personal, where(:personal => true)
  scope :non_personal, where(:personal => false)

  def self.naive_search(filter, keyword, selected_categories = [])
    # TODO: elasticsearch
    votes = Vote.includes(:issues, :propositions, :vote_connections)

    case filter
    when 'selected-categories'
      votes.select! do |v|
        v.issues.any? { |i| (i.categories & selected_categories).any? }
      end
    when 'not-connected'
      votes.select! { |v| v.vote_connections.empty? }
    else
      # ignore 'all' or others
    end

    if keyword.present?
      votes.select! do |v|
        v.propositions.any? { |e| e.plain_body.include? keyword } ||
          v.issues.any? { |e| e.description.include? keyword }
      end
    end

    votes.select { |e| e.issues.all?(&:processed?) }
  end

  def time_text
    I18n.l time, format: :short
  end

  def has_results?
    vote_results.size > 0
  end

  def inferred?
    non_personal? && has_results?
  end

  def non_personal?
    !personal?
  end

  def enacted_text
    enacted? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  def minutes_url
    # FIXME: hardcoded session
    I18n.t("app.external.urls.minutes") % ['2011-2012', time.strftime("%y%m%d")]
  end

  private

  def fetch_stats
    Hdo::Stats::VoteCounts.new self
  end

end # Vote
