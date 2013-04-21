class Question < ActiveRecord::Base
  include Workflows::BaseQuestionAndAnswerWorkflow
  attr_accessible :body, :from_name, :from_email, :representative, :issues, :representative_id

  belongs_to :representative
  has_many :answers, dependent: :destroy

  has_and_belongs_to_many :issues, uniq: true, order: "updated_at DESC"

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

  def self.statuses
    workflow_spec.state_names.map &:to_s
  end

  def teaser
    body.truncate(100)
  end

  def status_text
    I18n.t "app.questions.status.#{status}"
  end
end
