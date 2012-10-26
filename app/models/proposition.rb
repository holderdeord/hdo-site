class Proposition < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire.settings(TireSettings.default) {
    mapping {
      indexes :description, type: :string, analyzer: TireSettings.default_analyzer
      indexes :plain_body, type: :string, analyzer: TireSettings.default_analyzer
      indexes :short_body, type: :string
      indexes :on_behalf_of, type: :string

      indexes :vote do
        indexes :slug
      end
    }
  }

  attr_accessible :description, :on_behalf_of, :body, :representative_id

  belongs_to :vote
  belongs_to :representative

  alias_method :delivered_by, :representative

  validates :body, presence: true
  validates_uniqueness_of :external_id, allow_nil: true # https://github.com/holderdeord/hdo-site/issues/138

  def plain_body
    Nokogiri::HTML.parse(body).inner_text.strip
  end

  def short_body
    plain_body.truncate(200)
  end

  def to_indexed_json
    to_json methods: [:plain_body, :short_body],
            include: {vote: {only: [:slug]} },
            only:    [:description, :on_behalf_of]
  end
end
