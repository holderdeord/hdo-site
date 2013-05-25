require 'spec_helper'

describe QuestionsController do
  let(:representative) { Representative.make!(:attending, email: 'representative@example.com') }

  let(:valid_attributes) do
    { body: 'Tekst', representative: representative, from_name: 'Ola', from_email: 'ola@nordmann.no' }
  end

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
      assigns(:answer).should be_nil
    end

    it 'only finds approved questions' do
      expect {
        get :show, id: Question.make!(status: 'pending')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'assigns approved answers as @answer' do
      question = Question.make!(status: 'approved')
      question.create_answer!(body: 'foo', representative: question.representative, status: 'approved')

      get :show, id: question

      assigns(:answer).should == question.answer
    end

    it 'ignores non-approved answers' do
      question = Question.make!(status: 'approved')
      question.create_answer!(body: 'foo', representative: question.representative, status: 'pending')

      get :show, id: question

      assigns(:answer).should be_nil
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
          post :create, question: valid_attributes
        }.to change(Question, :count).by(1)
      end

      it "assigns a newly created question as @question" do
        post :create, question: valid_attributes
        assigns(:question).should be_a(Question)
        assigns(:question).should be_persisted
      end

      it "redirects to the created question" do
        post :create, question: valid_attributes
        response.should have_rendered(:create)
      end

      it 'does not accepts a blank from_name' do
        post :create, question: valid_attributes.merge(from_name: '')

        q = assigns(:question)
        q.should_not be_valid

        response.should have_rendered(:new)
      end

      it 'does not accept a blank from_email' do
        post :create, question: valid_attributes.merge(from_email: '')

        q = assigns(:question)
        q.should_not be_valid

        response.should have_rendered(:new)
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

        assigns(:representatives).should_not be_nil
        assigns(:districts).should_not be_nil

        response.should render_template("new")
      end
    end
  end

  describe 'GET conduct' do
    it 'renders the code of conduct' do
      get :conduct
      response.should have_rendered(:_conduct)
    end
  end
end
