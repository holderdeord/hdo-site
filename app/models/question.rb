class Question < ActiveRecord::Base
  attr_accessible :title, :body, :from_name, :from_email

  validates :title,      presence: true, length: { maximum: 255 }
  validates :body,       presence: true
  validates :status,     presence: true, inclusion: { in: %w[pending rejected approved] }
  validates :from_email, email: true, allow_nil: true

  has_many :answers

  scope :approved, lambda { where(:status => 'approved') }

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

  private
end
