require 'spec_helper'

describe Admin::AnswersController do

  let(:question)       { Question.make!(status: 'approved') }
  let(:user)           { User.make! }
  let(:representative) { Representative.make! }
  let(:answer)         { question.answers.create!(valid_attributes) }

  def valid_attributes
    { body: 'text', :representative_id => representative.id }
  end

  def default_params
    { question_id: question }
  end

  before { sign_in user }

  describe "GET index" do
    it "assigns the question's answers as @answers" do
      a = answer

      get :index, default_params
      assigns(:answers_by_status).should eq({'pending' => [a]})
    end
  end

  describe "GET new" do
    it "assigns a new answer as @answer" do
      get :new, default_params
      assigns(:answer).should be_a_new(Answer)
    end
  end

  describe "GET edit" do
    it "assigns the requested answer as @answer" do
      get :edit, default_params.merge(id: answer.to_param)
      assigns(:answer).should eq(answer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Answer" do
        expect {
          post :create, default_params.merge(answer: valid_attributes)
        }.to change(question.answers, :count).by(1)
      end

      it "assigns a newly created answer as @answer" do
        post :create, default_params.merge(answer: valid_attributes)
        assigns(:answer).should be_a(Answer)
        assigns(:answer).should be_persisted
      end

      it "redirects to the list of answers" do
        post :create, default_params.merge(answer: valid_attributes)
        response.should redirect_to(admin_question_answers_path(question))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved answer as @answer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        post :create, default_params.merge(:answer => {})
        assigns(:answer).should be_a_new(Answer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        post :create, default_params.merge(answer: {  })
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested answer" do
        # Assuming there are no other answers in the database, this
        # specifies that the Answer created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Answer.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, default_params.merge(id: answer.to_param, answer: { "these" => "params"})
      end

      it "assigns the requested answer as @answer" do
        put :update, default_params.merge(id: answer.to_param, answer: valid_attributes)
        assigns(:answer).should eq(answer)
      end

      it "redirects to the answer" do
        put :update, default_params.merge(id: answer.to_param, answer: valid_attributes)
        response.should redirect_to(admin_question_answers_path(question))
      end
    end

    describe "with invalid params" do
      it "assigns the answer as @answer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        put :update, default_params.merge(id: answer.to_param, answer: {})
        assigns(:answer).should eq(answer)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Answer.any_instance.stub(:save).and_return(false)
        put :update, default_params.merge(id: answer.to_param, answer: {  })
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested answer" do
      a = answer

      expect {
        delete :destroy, default_params.merge(id: a.to_param)
      }.to change(question.answers, :count).by(-1)
    end

    it "redirects to the answers list" do
      delete :destroy, default_params.merge(id: answer.to_param)
      response.should redirect_to(admin_question_answers_path(question))
    end
  end

end
