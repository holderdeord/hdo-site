class Representative::QuestionsController < RepresentativeController
  def index
    @questions = Question.where("representative_id = ?", current_representative)
  end
end
