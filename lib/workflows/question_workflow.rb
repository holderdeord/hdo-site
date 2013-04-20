module Workflows
  module QuestionWorkflow
    def self.included(base)
      base.send :include, AnswerWorkflow
    end
  end
end
