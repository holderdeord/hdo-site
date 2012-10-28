class Topic < ActiveRecord::Base
  extend FriendlyId

  include Hdo::Model::HasFallbackImage

  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire.settings(TireSettings.default) {
    mapping {
      indexes :name, type: :string, analyzer: TireSettings.default_analyzer
      indexes :slug, type: :string, index: :not_analyzed
    }
  }

  attr_accessible :name, :issue_ids, :image
  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :issues,   uniq: true
  has_many                :promises, through: :issues

  friendly_id :name, use: :slugged

  image_accessor :image

  def self.column_groups
    all = order(:name)

    column_count = 3

    if all.size < column_count
      [all.to_a]
    else
      all.each_slice(all.size / column_count).to_a
    end
  end

  def previous_and_next(opts = {})
    topics = self.class.order(opts[:order] || :name)

    current_index = topics.to_a.index(self)

    prev_topic = topics[current_index - 1] if current_index > 0
    next_topic = topics[current_index + 1] if current_index < topics.size

    [prev_topic, next_topic]
  end

  def default_image
    "#{Rails.root}/app/assets/images/topic_icons/snakkeboble_venstre.png"
  end

  def downcased_name
    UnicodeUtils.downcase name
  end

end
