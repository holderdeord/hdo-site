# encoding: UTF-8

class Promise < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :parties, :general, :categories, :source, :body, :page, :date

  has_and_belongs_to_many :parties, order: :name, uniq: true
  has_and_belongs_to_many :categories, order: :name, uniq: true
  has_and_belongs_to_many :issues, order: :title, uniq: true

  validates_presence_of :source, :body, :external_id
  validates_uniqueness_of :external_id, :body
  validates_length_of :categories, minimum: 1
  validates_length_of :parties, minimum: 1

  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end

  def source_header
    # TODO: i18n

    case source
    when 'Partiprogram'
      'I partiprogrammet har partiet lovet følgende:'
    when 'Regjeringserklæring'
      'I regjeringserklæringen har partiet lovet følgende:'
    else
      raise "unknown source: #{source}"
    end
  end

  def party_names
    parties.map(&:name).to_sentence
  end

  def short_party_names
    parties.map(&:external_id).to_sentence
  end

  def to_indexed_json
    to_json methods: :party_names
  end
end
