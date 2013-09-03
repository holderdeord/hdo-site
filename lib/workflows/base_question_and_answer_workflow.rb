module Workflows
  module BaseQuestionAndAnswerWorkflow
    def self.included(base)
      base.send :include, Workflow
      base.workflow_column :status
      base.workflow do
        state :pending do
          event :approve, transitions_to: :approved
          event :reject,  transitions_to: :rejected
        end

        state :approved do
          event :reject, transitions_to: :rejected
        end

        state :rejected do
          event :approve, transitions_to: :approved
        end
      end

      base.scope :approved, -> { base.where(status: 'approved') }
      base.scope :pending,  -> { base.where(status: 'pending') }
      base.scope :rejected, -> { base.where(status: 'rejected') }
    end
  end
end