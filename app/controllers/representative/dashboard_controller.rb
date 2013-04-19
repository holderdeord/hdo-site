class Representative::DashboardController < RepresentativeController
  def index
    @pending_questions = Question.pending
  end
end