class Link < ActiveRecord::Base
  attr_accessible :external_id, :title, :href, :link_type, :link_sub_type
  validates :href, presence: true, uniqueness: true

  has_and_belongs_to_many :parliament_issues
end