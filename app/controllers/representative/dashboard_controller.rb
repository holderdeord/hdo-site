class Representative::DashboardController < RepresentativeController
  def index
    puts "in your index"
    @pending_questions = Question.pending
  end
end