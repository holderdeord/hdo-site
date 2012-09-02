class Issue < ActiveRecord::Base
  include Hdo::ModelHelpers::HasStatsCache
  extend FriendlyId

  attr_accessible :description, :title, :category_ids, :promise_ids, :topic_ids, :published

  validates_presence_of   :title
  validates_uniqueness_of :title

  has_and_belongs_to_many :topics,     uniq: true
  has_and_belongs_to_many :categories, uniq: true
  has_and_belongs_to_many :promises,   uniq: true

  belongs_to :last_updated_by, :foreign_key => 'last_updated_by_id', :class_name => 'User'

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

  def update_attributes_and_votes_for_user(attributes, votes, user)
    changed = false

    Array(votes).each do |data|
      existing = VoteConnection.where('vote_id = ? and issue_id = ?', data[:vote_id], id).first

      if existing && data[:direction] == 'unrelated'
        vote_connections.delete existing
        changed = true
      else
        if existing
          existing.attributes = data.except(:direction).merge(matches: data[:direction] == 'for')
          changed ||= existing.changed?
          existing.save!
        else
          vote_connections.create! vote_id:      vote_id,
                                   matches:      data[:direction] == 'for',
                                   comment:      data[:comment],
                                   weight:       data[:weight],
                                   description:  data[:description]
          changed = true
        end
      end
    end

    touch if changed

    # hacky..
    if attributes['category_ids'] && attributes['category_ids'].map(&:to_i).sort != category_ids.sort
      changed = true
    end


    self.attributes = attributes
    changed ||= self.changed?

    if changed
      self.last_updated_by = user
    end

    valid?
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

  def downcased_title
    @downcased_title ||= "#{UnicodeUtils.downcase title[0]}#{title[1..-1]}"
  end

  def published_text
    published? ? I18n.t('app.issues.edit.published') : I18n.t('app.issues.edit.not_published')
  end

  def published_state
    published? ? 'published' : 'not-published'
  end

  def last_updated_by_name
    last_updated_by ? last_updated_by.name : I18n.t('app.nobody')
  end

  private

  def fetch_stats
    Hdo::Stats::VoteScorer.new(self)
  end

end
