require "spec_helper"

describe ModerationMailer do
  let(:representative) { Representative.make! :confirmed }

  describe "Question approved emails" do
    let(:question) { Question.make! representative: representative }

    it "sets the representatives email address on his notification" do
      m = ModerationMailer.question_approved_representative_email(question)
      m.to.should eq [representative.email]
    end

    it "sets the users email address on his notification" do
      m = ModerationMailer.question_approved_user_email(question)
      m.to.should eq [question.from_email]
    end

    it "includes the question id in the reply-to address" do
      m = ModerationMailer.question_approved_user_email(question)
      m.reply_to.first["#{question.id}"].should_not be_nil
    end

    it "adds an email event to the question" do
      expect {
        ModerationMailer.question_approved_user_email(question)
        question.reload
      }.to change(question.email_events, :count).by 1
    end

    it "makes a bracketed email" do
      Hdo::Utils::OverrideMailRecipient.stub!(:delivering_email)
      mail = ModerationMailer.question_approved_representative_email(question)
      mail[:to].field.value.should eq "#{representative.name} <#{representative.email}>"
    end
  end

  describe "Answer approved emails" do
    let(:question) { Question.make! :approved, representative: representative }
    let(:answer) { Answer.make! question: question, representative: representative }

    it "sets the user's email address on his notification" do
      m = ModerationMailer.answer_approved_user_email(question)
      m.to.should eq [question.from_email]
    end

    it "adds an email event to the question" do
      expect {
        ModerationMailer.answer_approved_user_email(question)
        question.reload
      }.to change(question.email_events, :count).by 1
    end
  end
end
