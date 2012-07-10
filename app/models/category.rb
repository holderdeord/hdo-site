class Category < ActiveRecord::Base
  has_and_belongs_to_many :issues, :order => "last_update DESC"
  has_and_belongs_to_many :promises
  has_and_belongs_to_many :topics

  acts_as_tree :order => :name

  validates_uniqueness_of :name

  extend FriendlyId
  friendly_id :name, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def self.column_groups
    column_count = 3
    category_count = Category.count
    cat_groups = Category.where( :main => true).includes(:children) #.in_groups_of(Category.where(:main => true).count / 3, false)
    column_length = (category_count / column_count)

    lengths = []
    sum = 0
    prev_i = 0
    cat_groups.each_with_index do |cat_group, i|
      sum += (cat_group.children.count + 1)
      if(sum >= column_length)
        sum = 0
        lengths << (i - prev_i)
        prev_i = i
      end
    end

    categories = []

    lengths.each do |l|
      categories << cat_groups.shift(l)
    end

    categories << cat_groups
  end
end
