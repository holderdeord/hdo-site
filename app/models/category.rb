class Category < ActiveRecord::Base
  extend FriendlyId
  include ActsAsTree

  attr_accessible :name, :external_id

  has_and_belongs_to_many :parliament_issues, uniq: true, order: "last_update DESC"
  has_and_belongs_to_many :promises,          uniq: true
  has_and_belongs_to_many :issues,            uniq: true

  acts_as_tree order: :name

  validates :name,        presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true

  friendly_id :name, use: :slugged

  scope :all_with_children, includes(:children).all(order: :name)

  def self.column_groups column_count
    target_size  = Category.count / column_count
    parents      = Category.where(main: true).includes(:children).to_a

    groups, sum, prev_idx = [], 0, 0

    parents.dup.each_with_index do |parent, idx|
      sum += parent.children.size + 1

      if sum >= target_size
        sum = 0
        groups << parents.shift(idx - prev_idx)
        prev_idx = idx
      end
    end

    groups << parents # remainder

    groups
  end

  def all_promises
    Promise.joins(:categories).where("categories.id = ? or categories.parent_id = ?", id, id)
  end

  def human_name
    n = name

    case n
    when 'EFTA/EU', 'FN'
      n
    when 'FN-STYRKER'
      'FN-styrker'
    else
      "#{UnicodeUtils.upcase n[0]}#{UnicodeUtils.downcase n[1..-1]}"
    end
  end
end