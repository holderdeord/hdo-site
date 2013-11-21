class Proposition < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Hdo::Search::Index

  tire.settings(TireSettings.default) {
    mapping {
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :plain_body, type: :string, analyzer: TireSettings.default_analyzer
      indexes :on_behalf_of, type: :string

      indexes :vote do
        indexes :slug, index: :not_analyzed
      end
    }
  }
  update_index_on_change_of :votes, has_many: true

  attr_accessible :description, :on_behalf_of, :body, :representative_id

  has_and_belongs_to_many :votes, uniq: true
  has_many :proposition_connections, dependent: :destroy
  has_many :issues, through: :proposition_connections
  belongs_to :representative

  alias_method :delivered_by, :representative

  validates :body, presence: true
  validates_uniqueness_of :external_id, allow_nil: true # https://github.com/holderdeord/hdo-site/issues/138

  def plain_body
    Nokogiri::HTML.parse(body).xpath('//text()').map { |e| e.text.strip }.join(' ')
  end

  def short_body
    plain_body.truncate(200)
  end

  def to_indexed_json
    to_json methods: [:plain_body],
            include: {votes: {only: [:slug]} },
            only:    [:description, :on_behalf_of]
  end
end
