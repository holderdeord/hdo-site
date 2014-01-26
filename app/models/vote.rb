class Vote < ActiveRecord::Base
  extend FriendlyId

  include Hdo::Search::Index
  include Elasticsearch::Model::Callbacks

  settings(SearchSettings.default) {
    mappings {
      indexes :category_names, index: :not_analyzed
    }
  }
  update_index_on_change_of :propositions, :parliament_issues, has_many: true

  attr_accessible :for_count, :against_count, :absent_count,
                  :enacted, :personal, :subject, :time, :external_id

  has_and_belongs_to_many :parliament_issues, uniq: true
  has_and_belongs_to_many :propositions, uniq: true

  has_many :representatives, through: :vote_results, order: :last_name
  has_many :vote_results, dependent: :destroy,
                          before_add: :clear_stats_cache,
                          before_remove: :clear_stats_cache

  validates_length_of     :parliament_issues, minimum: 1
  validates_presence_of   :time, :external_id
  validates_uniqueness_of :external_id

  # timestamps are unique unless it's an alternate vote, in which case 'enacted' will not be the same
  validates_uniqueness_of :time, scope: :enacted

  friendly_id :timestamp_and_enacted, use: :slugged

  scope :latest,          ->(limit) { order(:time).reverse_order.limit(limit) }
  scope :personal,        -> { where(:personal => true) }
  scope :non_personal,    -> { where(:personal => false) }
  scope :with_results,    -> { includes(:parliament_issues, vote_results: {representative: {party_memberships: :party}}) }
  scope :since_yesterday, -> { where("created_at >= ?", 1.day.ago) }

  def self.admin_search(filter, query, selected_categories = [], limit = 100)
    query = '*' if query.blank?

    opts = {
      load: {
        include: [ :parliament_issues, :propositions ]
      }
    }

    response = search(opts) do |s|
      s.size limit

      s.query do |q|
        q.filtered do |f|
          f.query { |qr| qr.string query, default_operator: 'AND' }

          f.filter :term, processed: true

          if filter == 'selected-categories'
            f.filter :terms, category_names: selected_categories.map { |e| e.name }
          end
        end
      end
    end

    response.results
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
    I18n.t("app.external.urls.minutes") % [parliament_session.name, time.strftime("%y%m%d")]
  end

  def parliament_session
    ParliamentSession.for_date time
  end

  def parliament_period
    ParliamentPeriod.for_date time
  end

  def alternate_of?(other)
    time == other.time &&
      for_count == other.against_count &&
      against_count == other.for_count &&
      absent_count == other.absent_count &&
      enacted? != other.enacted?
  end

  def timestamp_and_enacted
    "#{time.to_i}#{enacted ? 'e' : 'ne'}"
  end

  def to_indexed_json
    data = as_json(include: {
      propositions:      { only: :description, methods: :plain_body },
      parliament_issues: { only: [:description, :external_id] }
    })

    data[:processed] = true
    data[:category_names] = Set.new

    parliament_issues.each do |pi|
      data[:processed] = false unless pi.processed?
      data[:category_names] += pi.categories.map { |e| e.name }
    end

    data.to_json
  end

  def stats
    @stats ||= Rails.cache.fetch(stats_cache_key) { Hdo::Stats::VoteCounts.new self }
  end

  private

  def clear_stats_cache(obj)
    Rails.cache.delete stats_cache_key
  end

  def stats_cache_key
    # TODO: if we switch to a cache store that persists between
    # deploys (like memcached), consider using ActiveSupport::Caching.expand_cache_key

    "#{cache_key}/stats"
  end
end # Vote
