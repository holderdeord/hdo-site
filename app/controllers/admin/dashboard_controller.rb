class Admin::DashboardController < AdminController
  def index
    @votes_by_date               = Vote.includes(:parliament_issues).latest(30).group_by { |v| v.time.to_date }
    @parliament_issues_by_status = ParliamentIssue.latest(10).group_by(&:status_text)
    @issues_by_status            = Issue.latest(10).group_by(&:status_text)
    @pending_questions           = Question.pending
    @questions_answer_pending    = Question.with_pending_answers

    published         = Issue.published
    proposition_count = Proposition.count
    promise_count     = Promise.count

    @issue_proposition_percentage = published.flat_map(&:proposition_ids).uniq.size * 100 / (proposition_count.zero? ? 1 : proposition_count)
    @issue_promise_percentage     = published.flat_map(&:promise_ids).uniq.size * 100 / (promise_count.zero? ? 1 : promise_count)
  end
end
