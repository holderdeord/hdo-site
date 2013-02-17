class Admin::DashboardController < AdminController
  def index
    @votes_by_date = Vote.includes(:parliament_issues).latest(30).group_by { |v| v.time.to_date }
    @parliament_issues_by_status = ParliamentIssue.latest(10).group_by(&:status_text)
    @issues_by_status = Issue.latest(10).group_by(&:status_text)
    @pending_questions = Question.pending
  end
end
