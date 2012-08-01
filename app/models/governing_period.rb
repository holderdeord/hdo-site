class GoverningPeriod < ActiveRecord::Base
  belongs_to :party
  attr_accessible :end_date, :start_date, :party

  validates_presence_of :party, :start_date

end
