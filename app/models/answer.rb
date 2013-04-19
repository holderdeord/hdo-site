class Answer < ActiveRecord::Base
  attr_accessible :body, :representative_id, :representative, :question, :question_id

  belongs_to :question
  belongs_to :representative

  validates :body,           presence: true
  validates :representative, presence: true
  validates :question,       presence: true

  STATUSES = %w[pending approved rejected]

  scope :approved, lambda { where(:status => 'approved').order('updated_at DESC') }
  scope :pending, lambda { where(:status => 'pending').order('created_at DESC') }

  def self.all_by_status
    grouped = all.group_by { |a| a.status }
    grouped.values.each do |answers|
      answers.sort_by! { |e| e.created_at }
    end

    grouped
  end

  def party
    representative.party_at created_at
  end

  def reject
    self.status = 'rejected'
  end

  def reject!
    reject
    save
  end

  def approve
    self.status = 'approved'
  end

  def approve!
    approve
    save
  end

  def rejected?
    status == 'rejected'
  end

  def approved?
    status == 'approved'
  end

  def pending?
    status == 'pending'
  end

end
