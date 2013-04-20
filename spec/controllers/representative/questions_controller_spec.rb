require 'spec_helper'

describe Representative::QuestionsController do

  let(:rep) { Representative.make! }
  before { sign_in rep }

  describe "GET index" do
    it "assigns approved questions" do
      question = Question.make!(status: 'approved', representative: rep)

      get :index, {}
      assigns(:questions).should eq([question])
    end
  end

  describe "GET show" do
    it "assigns the question" do
      question = Question.make!(status: 'approved', representative: rep)
      question.answers.create!(body: "answer", representative: rep)

      get :show, {id: question}
      assigns(:question).should eq question
    end
  end
end