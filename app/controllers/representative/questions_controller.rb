class Representative::QuestionsController < RepresentativeController
  def index
    @questions = Question.where("representative_id = ?", current_representative)
  end

  def show
    @question = Question.approved.find(params[:id])
    @answer = Answer.new(question: @question, representative: @question.representative)
  end

end
