# encoding: UTF-8

class Promise < ActiveRecord::Base
  paginates_per 50

  include Hdo::Search::Index
  add_index_callbacks partial_update: false

  settings(SearchSettings.default) {
    mappings {
      indexes :body, type: :string, analyzer: SearchSettings.default_analyzer
      indexes :party_names, index: :not_analyzed
      indexes :category_names, index: :not_analyzed
      indexes :parliament_period_name, type: :string, index: :not_analyzed
      indexes :promisor_name, type: :string, index: :not_analyzed
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
    if promisor.kind_of?(Party)
      [promisor]
    else
      promisor.parties
    end
  end

  def main_category
    categories.where(main: true).first || categories.first.parent
  end

  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end

  def party_names
    parties.map(&:name)
  end

  def short_party_names
    parties.map(&:external_id)
  end

  def promisor_name
    if promisor.kind_of?(Government)
      "Regjeringen #{promisor.name}"
    else
      promisor.name
    end
  end

  def category_names
    categories.map(&:human_name)
  end

  def parliament_period_name
    parliament_period.name
  end

  def future?
    # TODO: spec
    parliament_period.start_date > ParliamentPeriod.current.start_date
  end

  def as_indexed_json(options = nil)
    as_json only: :body, methods: [
      :party_names,
      :parliament_period_name,
      :promisor_name,
      :category_names
    ]
  end
end
