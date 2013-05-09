# encoding: UTF-8

class Promise < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Hdo::Search::Index

  tire.settings(TireSettings.default) {
    mapping {
      indexes :body, type: :string, analyzer: TireSettings.default_analyzer
      indexes :party_names, type: :string
    }
  }
  update_index_on_change_of :parties, has_many: true

  attr_accessible :parties, :general, :categories, :source, :body, :page, :parliament_period

  validates :body,        presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true
  validates :source,      presence: true

  has_and_belongs_to_many :parties,    uniq: true, order: :name
  has_and_belongs_to_many :categories, uniq: true, order: :name

  has_many :promise_connections, dependent: :destroy
  has_many :issues, through: :promise_connections

  belongs_to :parliament_period

  validates_length_of :categories, minimum: 1
  validates_length_of :parties,    minimum: 1
  validates_presence_of :parliament_period

  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end

  def party_names
    parties.map(&:name).to_sentence
  end

  def short_party_names
    parties.map(&:external_id).to_sentence
  end

  def to_indexed_json
    to_json methods: :party_names, only: :body
  end
end
