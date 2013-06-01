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
  end

  describe "Answer approved emails" do
    let(:question) { Question.make! :approved, representative: representative }
    let(:answer) { Answer.make! question: question, representative: representative }

    it "sets the representative's email address on his notification" do
      m = ModerationMailer.answer_approved_representative_email(question)
      m.to.should eq [representative.email]
    end

    it "sets the user's email address on his notification" do
      m = ModerationMailer.answer_approved_user_email(question)
      m.to.should eq [question.from_email]
    end
  end
end
