class ParliamentPeriod < ActiveRecord::Base
  include Hdo::Model::FixedDateRange

  has_many :promises
end
