class Issue < ActiveRecord::Base
  extend FriendlyId

  include Hdo::Model::HasStatsCache
  include Tire::Model::Search
  extend Hdo::Search::Index

  tire.settings(TireSettings.default) {
    mapping {
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :title,       type: :string, analyzer: TireSettings.default_analyzer, boost: 100
      indexes :status,      type: :string, index: :not_analyzed
      indexes :slug,        type: :string, index: :not_analyzed

      indexes :categories do
        indexes :name, type: :string, analyzer: TireSettings.default_analyzer
      end

      indexes :topics do
        indexes :name, type: :string, analyzer: TireSettings.default_analyzer
      end
    }
  }
  update_index_on_change_of :categories, :topics

  after_save do
    update_index if published?
  end

  before_destroy do
    destroy_associations # workaround https://github.com/rails/rails/issues/5332, should be fixed in 3.2.13
  end

  attr_accessible :description, :title, :category_ids, :promise_ids, :topic_ids, :status, :lock_version, :editor_id
  validates :title, presence: true, uniqueness: true

  STATUSES = %w[published in_progress shelved]
  validates_inclusion_of :status, in: STATUSES

  has_and_belongs_to_many :topics,     uniq: true
  has_and_belongs_to_many :categories, uniq: true

  belongs_to :last_updated_by, foreign_key: 'last_updated_by_id', class_name: 'User'
  belongs_to :editor, class_name: 'User'

  has_many :vote_connections, dependent:     :destroy,
                              before_add:    :clear_stats_cache,
                              before_remove: :clear_stats_cache

  has_many :promise_connections, dependent:     :destroy,
                                 before_add:    :clear_stats_cache,
                                 before_remove: :clear_stats_cache

  has_many :votes,    through: :vote_connections,    order: :time
  has_many :promises, through: :promise_connections

  friendly_id :title, use: :slugged

  scope :vote_ordered, includes(:votes).order('votes.time DESC')
  scope :published, where(:status => 'published')
  scope :latest, lambda { |limit| order(:updated_at).reverse_order.limit(limit) }
  scope :random, lambda { |limit| order("random()").limit(limit) }

  def previous_and_next(opts = {})
    issues = self.class
    issues = opts[:policy].scope if opts[:policy]
    issues = issues.order(opts[:order] || :title)

    current_index = issues.to_a.index(self)

    prev_issue = issues[current_index - 1] if current_index > 0
    next_issue = issues[current_index + 1] if current_index < issues.size

    [prev_issue, next_issue]
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
    I18n.t("app.issues.status.#{status}")
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

  def editor_name
    editor ? editor.name : I18n.t('app.nobody')
  end

  def to_indexed_json
    to_json include: [:topics, :categories]
  end

  def to_json_with_stats
    to_json methods: [:stats, :accountability]
  end

  def accountability
    # TODO: cache this when it's being used for real.
    Hdo::Stats::AccountabilityScorer.new(self)
  end

  private

  def fetch_stats
    Hdo::Stats::VoteScorer.new(self)
  end
end
