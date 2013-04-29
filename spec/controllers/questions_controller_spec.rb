require 'spec_helper'

describe QuestionsController do
  let(:representative) { Representative.make! }
  let(:valid_attributes) { {body: 'Tekst', representative: representative } }

  describe "GET index" do
    it "assigns all approved questions as @questions" do
      pending = Question.make!
      approved = Question.make!(status: 'approved')

      get :index
      assigns(:questions).should eq([approved])
    end
  end

  describe "GET show" do
    it "assigns the requested question as @question" do
      question = Question.make!(status: 'approved')
      get :show, id: question.to_param
      assigns(:question).should eq(question)
    end

    it 'only finds approved questions' do
      get :show, id: Question.make!(status: 'pending')
      response.should be_not_found
    end
  end

  describe "GET new" do
    it "assigns a new question as @question" do
      get :new
      assigns(:question).should be_a_new(Question)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Question" do
        expect {
          post :create, {question: valid_attributes}
        }.to change(Question, :count).by(1)
      end

      it "assigns a newly created question as @question" do
        post :create, {question: valid_attributes}
        assigns(:question).should be_a(Question)
        assigns(:question).should be_persisted
      end

      it "redirects to the created question" do
        post :create, {question: valid_attributes}
        response.should redirect_to(Question.last)
      end

      it 'accepts a blank from_name and persists it as nil' do
        post :create, { question: valid_attributes.merge('from_name' => '') }
        assigns(:question).should be_a(Question)
        assigns(:question).from_name.should be_nil
      end

      it 'accepts a blank from_email and persists it as nil' do
        post :create, { question: valid_attributes.merge('from_email' => '') }
        assigns(:question).should be_a(Question)
        assigns(:question).from_name.should be_nil
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved question as @question" do
        # Trigger the behavior that occurs when invalid params are submitted
        Question.any_instance.stub(:save).and_return(false)
        post :create, {question: {  }}
        assigns(:question).should be_a_new(Question)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Question.any_instance.stub(:save).and_return(false)
        post :create, {question: {  }}
        response.should render_template("new")
      end
    end
  end
end
