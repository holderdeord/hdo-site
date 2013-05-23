require 'spec_helper'

describe Admin::QuestionsController do

  before(:each) do
    @request.env['HTTP_REFERER'] = admin_questions_path
  end

  context "not superadmin" do
    let(:user) { User.make! role: 'contributor' }
    before { sign_in user }

    describe "GET index" do
      it "assigns all questions grouped by status" do
        question = Question.make!

        get :index, {}
        assigns(:questions_by_status).should eq({'pending' => [question]})
      end
    end

    describe "PUT approve" do
      it "does not approve the requested question" do
        question = Question.make!

        put :approve, {:id => question.to_param}
        question.reload.should_not be_approved
      end
    end

    describe "PUT reject" do
      it "does not reject the requested question" do
        question = Question.make!

        put :reject, {:id => question.to_param}
        question.reload.should be_pending
      end
    end

  end

  context "superadmin" do
    let(:user) { User.make! role: 'superadmin' }
    before { sign_in user }

    describe "GET index" do
      it "assigns all questions grouped by status" do
        question = Question.make!

        get :index, {}
        assigns(:questions_by_status).should eq({'pending' => [question]})
      end
    end

    describe "PUT approve" do
      it "updates the requested question" do
        question = Question.make!

        put :approve, {:id => question.to_param}
        question.reload.should be_approved
      end

      it "redirects to questions#index" do
        question = Question.make!

        put :approve, {:id => question.to_param}
        response.should redirect_to(admin_questions_path)
      end

      it "informs the user if save fails" do
        question = Question.make!
        Question.any_instance.should_receive(:save).and_return false

        put :reject, {:id => question.to_param}
        response.should redirect_to(admin_questions_path)
        flash.should_not be_empty
      end
    end

    describe "PUT reject" do
      it "updates the requested question" do
        question = Question.make!

        put :reject, {:id => question.to_param}
        question.reload.should be_rejected
      end

      it "redirects to questions#index" do
        question = Question.make!

        put :reject, {:id => question.to_param}
        response.should redirect_to(admin_questions_path)
      end

      it "informs the user if save fails" do
        question = Question.make!
        Question.any_instance.should_receive(:save).and_return false

        put :reject, {:id => question.to_param}
        response.should redirect_to(admin_questions_path)
        flash.should_not be_empty
      end
    end

    describe "PUT edit" do
      let(:question) { Question.make! }

      it "fetches the question" do
        get :edit, id: question.id
        assigns(:question).should eq question
      end

      it "lets you add issues" do
        issue = Issue.make!

        put :update, id: question.id, question: { issues: [issue.id] }

        question.reload.issues.should eq [issue]
      end

      it "removes issues" do
        issue = Issue.make!
        question = Question.make!(issues: [issue])

        put :update, id: question.id, question: {}

        question.reload.issues.should be_empty
      end

      it 'sets question status' do
        question = Question.make!(status: 'pending')

        put :update, id: question, question: {status: 'approved' }

        question.reload.should be_approved
      end

      it 'sets answer status' do
        question = Question.make!(status: 'approved')
        answer = question.create_answer!(representative: question.representative, body: 'foo', status: 'pending')

        put :update, id: question, question: {answer: {status: 'approved'}}

        question.reload.answer.should be_approved
      end
    end
  end

end
