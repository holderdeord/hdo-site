class Proposition < ActiveRecord::Base
  belongs_to :vote
  belongs_to :representative

  alias_method :delivered_by, :representative
end
