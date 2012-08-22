class Issue < ActiveRecord::Base
  include Hdo::ModelHelpers::HasStatsCache
  extend FriendlyId

  attr_accessible :description, :title, :category_ids, :promise_ids, :topic_ids, :published

  validates_presence_of   :title
  validates_uniqueness_of :title

  has_and_belongs_to_many :topics,     uniq: true
  has_and_belongs_to_many :categories, uniq: true, order: :name
  has_and_belongs_to_many :promises,   uniq: true

  #
  # Whenever a issue is updated, we remove and re-create all vote_connection associations.
  # That means clearing the cache in before_add and before_remove is good enough.
  #
  # If we change how the connections are updated, this will need to be revised.
  #

  has_many :vote_connections, :dependent     => :destroy,
                              :before_add    => :clear_stats_cache,
                              :before_remove => :clear_stats_cache

  has_many :votes, :through => :vote_connections, :order => :time

  friendly_id :title, :use => :slugged

  scope :vote_ordered, includes(:votes).order('votes.time DESC')
  scope :published, where(:published => true)

  def vote_for?(vote_id)
    vote_connections.any? { |vd| vd.matches? && vd.vote_id == vote_id  }
  end

  def vote_against?(vote_id)
    vote_connections.any? { |vd| !vd.matches? && vd.vote_id == vote_id }
  end

  def connection_for(vote)
    vote_connections.where(:vote_id => vote.id).first
  end

  def downcased_title
    @downcased_title ||= "#{UnicodeUtils.downcase title[0]}#{title[1..-1]}"
  end

  def published_text
    published? ? I18n.t('app.yes') : I18n.t('app.no')
  end

  private

  def fetch_stats
    Hdo::Stats::VoteScorer.new(self)
  end

end
