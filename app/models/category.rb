class Category < ActiveRecord::Base
  extend FriendlyId
  include ActsAsTree

  attr_accessible :name

  has_and_belongs_to_many :parliament_issues, :order => "last_update DESC"
  has_and_belongs_to_many :promises
  has_and_belongs_to_many :issues

  acts_as_tree :order => :name

  validates_uniqueness_of :name

  friendly_id :name, :use => :slugged

  scope :all_with_children, includes(:children).all(:order => :name)

  def self.column_groups
    column_count = 3
    target_size  = Category.count / column_count
    parents      = Category.where(:main => true).includes(:children).to_a

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

  def human_name
    n = name

    case n
    when 'EFTA/EU'
      n
    else
      fixed_name = "#{UnicodeUtils.upcase n[0]}#{UnicodeUtils.downcase n[1..-1]}"
      fixed_name
    end
  end
end