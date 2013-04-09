class Question < ActiveRecord::Base
  attr_accessible :title, :body, :from_name, :from_email

  STATUSES = %w[pending approved rejected]

  validates :body,       presence: true
  validates :status,     presence: true, inclusion: { in: STATUSES }
  validates :from_email, email: true, allow_nil: true

  has_many :answers, dependent: :destroy

  scope :approved, lambda { where(:status => 'approved').order('updated_at DESC') }
  scope :pending, lambda { where(:status => 'pending').order('created_at DESC') }

  def self.all_by_status
    grouped = all.group_by { |q| q.status }
    grouped.values.each do |qs|
      qs.sort_by! { |e| e.created_at }
    end

    grouped
  end

  def teaser
    body.truncate(100)
  end

  def pending?
    status == 'pending'
  end

  def rejected?
    status == 'rejected'
  end

  def approved?
    status == 'approved'
  end

  def status_text
    I18n.t "app.questions.status.#{status}"
  end
end
