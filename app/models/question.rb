class Question < ActiveRecord::Base
  include Workflows::QuestionWorkflow
  attr_accessible :body, :from_name, :from_email, :representative

  belongs_to :representative
  has_many :answers, dependent: :destroy

  validates :body,           presence: true
  validates :from_email,     email: true, allow_nil: true
  validates :representative, presence: true # TODO: what representatives can be asked questions? (time)

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

  def status_text
    I18n.t "app.questions.status.#{status}"
  end
end
