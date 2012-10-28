class Issue < ActiveRecord::Base
  extend FriendlyId
  include Hdo::Model::HasStatsCache
  include Tire::Model::Search

  tire.settings(TireSettings.default) {
    mapping {
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :title,       type: :string, analyzer: TireSettings.default_analyzer, boost: 100
      indexes :status,      type: :string, index: :not_analyzed
    }
  }

  after_save do
    update_index if published?
  end

  attr_accessible :description, :title, :category_ids, :promise_ids, :topic_ids, :status
  validates :title, presence: true, uniqueness: true

  STATUSES = %w[in_progress shelved published]
  validates_inclusion_of :status, in: STATUSES

  has_and_belongs_to_many :topics,     uniq: true
  has_and_belongs_to_many :categories, uniq: true
  has_and_belongs_to_many :promises,   uniq: true

  belongs_to :last_updated_by, foreign_key: 'last_updated_by_id', class_name: 'User'

  has_many :vote_connections, dependent:     :destroy,
                              before_add:    :clear_stats_cache,
                              before_remove: :clear_stats_cache

  has_many :votes, through: :vote_connections, order: :time

  friendly_id :title, use: :slugged

  scope :vote_ordered, includes(:votes).order('votes.time DESC')
  scope :published, where(:status => 'published')

  def previous_and_next(opts = {})
    issues = self.class.order(opts[:order] || :title)
    issues = issues.published if opts[:published_only]

    current_index = issues.to_a.index(self)

    prev_issue = issues[current_index - 1] if current_index > 0
    next_issue = issues[current_index + 1] if current_index < issues.size

    [prev_issue, next_issue]
  end

  def update_attributes_and_votes_for_user(attributes, votes, user)
    changed = false

    Array(votes).each do |vote_id, data|
      existing = VoteConnection.where('vote_id = ? and issue_id = ?', vote_id, id).first

      if data[:direction] == 'unrelated'
        if existing
          vote_connections.delete existing
          changed = true
        end
      else
        attrs = data.except(:direction, :proposition_type).merge(matches: data[:direction] == 'for', vote_id: vote_id)

        if existing
          changed ||= update_vote_proposition_type existing.vote, data[:proposition_type]

          existing.attributes = attrs
          changed ||= existing.changed?

          existing.save!
        else
          new_connection = vote_connections.create!(attrs)
          update_vote_proposition_type new_connection.vote, data[:proposition_type]
          changed = true
        end
      end
    end

    touch if changed

    if attributes
      # TODO: find a better way to do this!

      if attributes['category_ids'] && attributes['category_ids'].reject(&:empty?).map(&:to_i).sort != category_ids.sort
        changed = true
      end

      if attributes['promise_ids'] && attributes['promise_ids'].reject(&:empty?).map(&:to_i).sort != promise_ids.sort
        changed = true
      end

      if attributes['topic_ids'] && attributes['topic_ids'].reject(&:empty?).map(&:to_i).sort != topic_ids.sort
        changed = true
      end

      self.attributes = attributes
      changed ||= self.changed?
    end

    if changed
      self.last_updated_by = user
    end

    save
  end

  def update_vote_proposition_type vote, proposition_type
    vote.proposition_type = proposition_type
    changed = vote.changed?
    vote.save
    changed
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

  def status_text
    I18n.t("app.issues.statuses.#{status}")
  end

  def published_state
    published? ? 'published' : 'not-published'
  end

  def published?
    status == 'published'
  end

  def last_updated_by_name
    last_updated_by ? last_updated_by.name : I18n.t('app.nobody')
  end

  private

  def fetch_stats
    Hdo::Stats::VoteScorer.new(self)
  end
end
