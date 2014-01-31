class Proposition < ActiveRecord::Base
  paginates_per 20

  include Hdo::Search::Index
  include Elasticsearch::Model::Callbacks

  settings(SearchSettings.default) {
    mappings {
      indexes :description, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :plain_body, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :simple_description, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :simple_body, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :on_behalf_of, type: :string
      indexes :vote_time, type: :date
      indexes :status, type: :string, index: :not_analyzed
      indexes :parliament_session_name, type: :string, index: :not_analyzed
      indexes :id, type: :integer, index: :not_analyzed

      indexes :votes do
        indexes :slug, index: :not_analyzed
      end
    }
  }
  update_index_on_change_of :votes, has_many: true

  attr_accessible :description, :on_behalf_of, :body, :representative_id, :simple_description, :simple_body, :status

  has_and_belongs_to_many :votes, uniq: true
  has_many :proposition_connections, dependent: :destroy
  has_many :issues, through: :proposition_connections

  has_many :proposition_endorsements, dependent: :destroy

  validates :body, presence: true
  validates :status, presence: true, inclusion: {in: %w[pending published]}
  validates :simple_description, presence: true, if: :published?
  validates :simple_description, length: {minimum: 1}, allow_nil: true
  validates :simple_body, length: {minimum: 1}, allow_nil: true

  validates_uniqueness_of :external_id, allow_nil: true # https://github.com/holderdeord/hdo-site/issues/138

  scope :published, -> { where(status: 'published') }
  scope :vote_ordered, -> { includes(:votes).order('votes.time DESC') }

  def plain_body
    Nokogiri::HTML.parse(body).xpath('//text()').map { |e| e.text.strip }.join(' ')
  end

  def vote_time
    @vote_time ||= votes.first.try(:time)
  end

  def parliament_session
    @parliament_session ||= ParliamentSession.for_date(vote_time)
  end

  def parliament_session_name
    parliament_session.try(:name)
  end

  def pending?
    status == 'pending'
  end

  def published?
    status == 'published'
  end

  def proposers
    proposition_endorsements.map(&:proposer)
  end

  def add_proposer(proposer)
    proposition_endorsements.create!(proposer: proposer)
  end

  def previous
    return unless vote_time

    relation = self.class.includes(:votes).where("votes.time < ?", vote_time).order('votes.time DESC')
    relation.first
  end

  def next
    return unless vote_time

    relation = self.class.includes(:votes).where("votes.time > ?", vote_time).order('votes.time')
    relation.first
  end

  def source_guess
    @source_guess ||= Hdo::Utils::PropositionSourceGuesser.parties_for("#{on_behalf_of} #{description}")
  end

  def as_indexed_json(options = nil)
    methods = [:plain_body]
    methods += [:parliament_session_name, :vote_time] if votes.any?

    as_json methods: methods,
            include: {votes: {only: [:slug]} },
            only:    [:description, :on_behalf_of, :status, :id, :simple_description, :simple_body]
  end
end
