require 'spec_helper'

describe QuestionsHelper do
  it 'has {question,answer}_status_options' do
    @answer = Answer.make!
    @question = @answer.question
    
    helper.question_status_options.should be_kind_of String
    helper.answer_status_options.should be_kind_of String
  end
end
