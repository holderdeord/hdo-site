require 'spec_helper'

describe Admin::QuestionsController do

  before(:each) do
    @request.env['HTTP_REFERER'] = admin_questions_path
  end

  context "not superadmin" do
    let(:user) { User.make! role: 'contributor' }
    before { sign_in user }

    describe "GET edit" do
      it "is unauthorized" do
        get :edit, id: Question.make!
        response.status.should eq 401
      end
    end

    describe "PUT edit" do
      it "cannot edit questions" do
        question = Question.make!(status: 'pending')

        put :update, id: question, question: {status: 'approved' }

        question.reload.should_not be_approved
        response.status.should eq 401
      end
    end

  end

  context "superadmin" do
    let(:user) { User.make! role: 'superadmin' }
    before { sign_in user }

    describe "GET index" do
      it "assigns pending questions" do
        q = Question.make!

        get :index

        assigns(:questions_pending).should eq [q]
      end

      it "assigns questions with pending answers" do
        q = Question.make! :approved
        Answer.make! question: q

        get :index

        assigns(:questions_answer_pending).should eq [q]
      end

      it "assigns rejected questions" do
        q = Question.make! status: 'rejected'

        get :index

        assigns(:questions_rejected).should eq [q]
      end

      it "assigns questions with rejected answers" do
        q = Question.make! :approved
        Answer.make! question: q, status: 'rejected'

        get :index

        assigns(:questions_answer_rejected).should eq [q]
      end

      it "assigns approved questions and answers" do
        q = Question.make! :approved
        Answer.make! question:q, status: 'approved'

        get :index

        assigns(:questions_approved).should eq [q]
      end

      it "assigns unanswered questions" do
        q = Question.make! :approved

        get :index

        assigns(:questions_unanswered).should eq [q]
      end
    end

    describe "PUT edit" do
      let(:question) { Question.make! }

      it "redirects form edit page if read_only" do
        AppConfig.any_instance.stub(:read_only).and_return(true)
        get :edit, id: question
        response.code.should eq '307'
      end

      it "redirects from put update if read_only" do
        AppConfig.any_instance.stub(:read_only).and_return(true)
        put :update, id: question
        response.code.should eq '307'
      end

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

      it 'sets the internal comment' do
        put :update, id: question, question: { internal_comment: 'doobeedoo' }

        question.reload.internal_comment.should eq 'doobeedoo'
      end

      it 'sets the question body' do
        put :update, id: question, question: { body: 'doobeedoo' }

        question.reload.body.should eq 'doobeedoo'
      end

      it 'sets the answer body' do
        question = Question.make!(status: 'approved')
        answer = question.create_answer!(representative: question.representative, body: 'foo', status: 'pending')

        put :update, id: question, question: {
          answer: {
            body: 'bar'
          }
        }

        question.reload.answer.body.should eq 'bar'
      end
    end

    describe "emails" do
      let(:representative) { Representative.make! :confirmed }
      let(:question) { Question.make! :approved, representative: representative }

      describe "approving questions" do
        it "can send the user an email" do
          ModerationMailer.should_receive(:question_approved_user_email).with(question).and_call_original

          get :question_approved_email_user, id: question
        end

        it "can send the representative an email" do
          ModerationMailer.should_receive(:question_approved_representative_email).with(question).and_call_original

          get :question_approved_email_rep, id: question
        end

        it "does not send an uninvited representative e-mails" do
          representative = Representative.make! :attending
          question = Question.make! representative: representative

          ModerationMailer.should_not_receive(:question_approved_representative_email)
          get :question_approved_email_rep, id: question
        end
      end

      describe "approving answers" do
        it "can send the user an email" do
          ModerationMailer.should_receive(:answer_approved_user_email).with(question).and_call_original

          get :answer_approved_email_user, id: question
        end
      end
    end
  end

end
