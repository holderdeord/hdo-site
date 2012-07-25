class Proposition < ActiveRecord::Base
  belongs_to :vote
  belongs_to :representative

  alias_method :delivered_by, :representative

  validates_presence_of :body, :description
end
