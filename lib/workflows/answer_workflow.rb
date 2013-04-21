module Workflows
  module AnswerWorkflow
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

      base.scope :approved, lambda { where(:status => 'approved').order('updated_at DESC') }
      base.scope :pending, lambda { where(:status => 'pending').order('created_at DESC') }
    end
  end
end