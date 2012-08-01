class Topic < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :description, :title, :category_ids, :promise_ids, :field_ids

  validates_presence_of :title
  validates_uniqueness_of :title

  has_and_belongs_to_many :fields
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promises

  has_many :vote_connections, :dependent     => :destroy,
                              :before_add    => :clear_stats_cache,
                              :before_remove => :clear_stats_cache

  has_many :votes, :through => :vote_connections, :order => :time

  friendly_id :title, :use => :slugged

  # TODO: rename to #scorer, #scores
  def stats
    Rails.cache.fetch(stats_cache_key) { Hdo::Stats::VoteScorer.new(self) }
  end

  def vote_for?(vote_id)
    vote_connections.any? { |vd| vd.matches? && vd.vote_id == vote_id  }
  end

  def vote_against?(vote_id)
    vote_connections.any? { |vd| !vd.matches? && vd.vote_id == vote_id }
  end

  def connection_for(vote)
    vote_connections.where(:vote_id => vote.id).first
  end

  private

  def clear_stats_cache(vote_connection)
    Rails.cache.delete stats_cache_key
  end

  def stats_cache_key
    "#{cache_key}/stats"
  end

end
