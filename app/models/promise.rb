# encoding: UTF-8

class Promise < ActiveRecord::Base
  include Hdo::Search::Index
  include Elasticsearch::Model::Callbacks

  settings(SearchSettings.default) {
    mappings {
      indexes :body, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :party_names, type: :string
      indexes :parliament_period_name, type: :string, index: :not_analyzed
    }
  }
  update_index_on_change_of :parties, has_many: true

  attr_accessible :promisor, :general, :categories, :source, :body, :page, :parliament_period

  validates :body,              presence: true, uniqueness: {scope: :parliament_period_id}
  validates :external_id,       presence: true, uniqueness: true
  validates :source,            presence: true
  validates :parliament_period, presence: true
  validates :promisor,          presence: true

  has_and_belongs_to_many :categories, uniq: true, order: :name

  has_many :promise_connections, dependent: :destroy
  has_many :issues, through: :promise_connections

  belongs_to :parliament_period
  belongs_to :promisor, polymorphic: true

  validates_length_of :categories, minimum: 1

  def self.parliament_periods
    ParliamentPeriod.joins(:promises).uniq.order(:start_date)
  end

  def parties
    case promisor_type
    when 'Party'
      [promisor]
    when 'Government'
      promisor.parties
    else
      raise "invalid promisor_type: #{promisor_type.inspect}"
    end
  end

  def main_category
    categories.where(main: true).first || categories.first.parent
  end

  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end

  def party_names
    parties.map(&:name).to_sentence
  end

  def short_party_names
    parties.map(&:external_id).to_sentence
  end

  def parliament_period_name
    parliament_period.name
  end

  def future?
    # TODO: make this actually check the date when we handle multiple periods
    parliament_period.external_id != '2009-2013'
  end

  def to_indexed_json
    to_json methods: [:party_names, :parliament_period_name], only: :body
  end
end
