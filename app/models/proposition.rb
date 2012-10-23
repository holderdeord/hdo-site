class Proposition < ActiveRecord::Base
  include Hdo::Model::Searchable

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
    to_json methods: [:short_body], include: [:vote]
  end
end
