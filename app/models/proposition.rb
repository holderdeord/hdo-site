class Proposition < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Hdo::Search::Index

  tire.settings(TireSettings.default) {
    mapping {
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :plain_body, type: :string, analyzer: TireSettings.default_analyzer
      indexes :simple_description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :simple_body, type: :string, analyzer: TireSettings.default_analyzer
      indexes :on_behalf_of, type: :string
      indexes :vote_time, type: :date
      indexes :status, type: :string, index: :not_analyzed
      indexes :parliament_session_name, type: :string, index: :not_analyzed

      indexes :votes do
        indexes :slug, index: :not_analyzed
      end
    }
  }
  update_index_on_change_of :votes, has_many: true

  attr_accessible :description, :on_behalf_of, :body, :representative_id, :simple_description, :simple_body, :status
  attr_accessible :source_slugs # TODO: convert to polymorphic Proposition#proposers

  has_and_belongs_to_many :votes, uniq: true
  has_many :proposition_connections, dependent: :destroy
  has_many :issues, through: :proposition_connections
  belongs_to :representative

  alias_method :delivered_by, :representative

  validates :body, presence: true
  validates :status, presence: true, inclusion: {in: %w[pending published]}

  validates_uniqueness_of :external_id, allow_nil: true # https://github.com/holderdeord/hdo-site/issues/138

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

  def previous
    self.class.where('id > ?', id).order(:id).reverse_order.first
  end

  def next
    self.class.where('id < ?', id).order(:id).reverse_order.first
  end

  def source_guess
    @source_guess ||= Hdo::Utils::PropositionSourceGuesser.parties_for(on_behalf_of + ' ' + description)
  end

  def to_indexed_json
    methods = [:plain_body]
    methods += [:parliament_session_name, :vote_time] if votes.any?

    to_json methods: methods,
            include: {votes: {only: [:slug]} },
            only:    [:description, :on_behalf_of, :status, :id, :simple_description, :simple_body]
  end
end
