class Proposition < ActiveRecord::Base
  belongs_to :vote
  belongs_to :delivered_by, :class_name => "Representative"
end
