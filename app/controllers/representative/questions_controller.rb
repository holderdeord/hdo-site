class Representative::QuestionsController < RepresentativeController
  def show
    @question = Question.approved.find(params[:id])
    @answer = Answer.new(question: @question, representative: @question.representative)
  end
end
