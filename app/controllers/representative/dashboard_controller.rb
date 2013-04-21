class Representative::DashboardController < RepresentativeController
  def index
    @questions = Question.approved.where("representative_id = ?", current_representative)
  end
end