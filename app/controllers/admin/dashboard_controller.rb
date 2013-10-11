class Admin::DashboardController < AdminController
  def index
    @votes_by_date               = Vote.includes(:parliament_issues).latest(30).group_by { |v| v.time.to_date }
    @parliament_issues_by_status = ParliamentIssue.latest(10).group_by(&:status_text)
    @issues_by_status            = Issue.latest(10).group_by(&:status_text)
    @pending_questions           = Question.pending
    @questions_answer_pending    = Question.with_pending_answers

    published     = Issue.published
    vote_count    = Vote.count
    promise_count = Promise.count

    @issue_vote_percentage       = published.flat_map(&:vote_ids).uniq.size * 100 / (vote_count.zero? ? 1 : vote_count)
    @issue_promise_percentage    = published.flat_map(&:promise_ids).uniq.size * 100 / (promise_count.zero? ? 1 : promise_count)
  end
end
