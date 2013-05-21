require 'spec_helper'

describe RepresentativeController do
  let(:question)       { Question.make!(status: 'approved') }
  let(:representative) { Representative.make! :confirmed }

  describe 'GET index' do
    it 'renders the dashboard' do
      sign_in representative

      get :index
      response.should have_rendered(:index)
    end

    it 'does not render the dashboard if unauthorized' do
      get :index
      response.should redirect_to(new_representative_session_path)
    end
  end

  describe "GET show" do
    it "assigns the question" do
      sign_in representative

      question = Question.make!(status: 'approved', representative: representative)
      question.create_answer!(body: "answer", representative: representative)

      get :show_question, id: question

      assigns(:question).should eq question
    end
  end

  describe "POST create_answer" do
    let(:answer) { question.create_answer!(valid_attributes) }
    before { sign_in representative }

    def valid_attributes
      { body: 'text', :representative_id => representative.id, question_id: question.id }
    end

    def default_params
      { id: question }
    end

    describe "with valid params" do
      it "creates a new Answer" do
        post :create_answer, default_params.merge(answer: valid_attributes)
        question.reload.answer.should be_a(Answer)
      end

      it "assigns a newly created answer as @answer" do
        post :create_answer, default_params.merge(answer: valid_attributes)
        assigns(:answer).should be_a(Answer)
        assigns(:answer).should be_persisted
      end

      it "redirects to the dashboard" do
        post :create_answer, default_params.merge(answer: valid_attributes)
        response.should redirect_to(representative_root_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved answer as @answer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        post :create_answer, default_params.merge(:answer => {})
        assigns(:answer).should be_a_new(Answer)
      end
    end
  end
end
