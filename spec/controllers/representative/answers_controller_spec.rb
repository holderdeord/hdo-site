require 'spec_helper'

describe Representative::AnswersController do

  let(:question)       { Question.make!(status: 'approved') }
  let(:user)           { User.make! }
  let(:representative) { Representative.make! }
  let(:answer)         { question.create_answer!(valid_attributes) }

  def valid_attributes
    { body: 'text', :representative_id => representative.id, question_id: question.id }
  end

  def default_params
    { question_id: question }
  end

  before { sign_in representative }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Answer" do
        post :create, default_params.merge(answer: valid_attributes)
        question.reload.answer.should be_a(Answer)
      end

      it "assigns a newly created answer as @answer" do
        post :create, default_params.merge(answer: valid_attributes)
        assigns(:answer).should be_a(Answer)
        assigns(:answer).should be_persisted
      end

      it "redirects to the list of answers" do
        post :create, default_params.merge(answer: valid_attributes)
        response.should redirect_to(representative_question_path(question))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved answer as @answer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        post :create, default_params.merge(:answer => {})
        assigns(:answer).should be_a_new(Answer)
      end

    end
  end
end
