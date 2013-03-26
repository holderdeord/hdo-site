class Admin::DashboardController < AdminController
  def index
    @votes_by_date               = Vote.includes(:parliament_issues).latest(30).group_by { |v| v.time.to_date }
    @parliament_issues_by_status = ParliamentIssue.latest(10).group_by(&:status_text)
    @issues_by_status            = Issue.latest(10).group_by(&:status_text)
    @pending_questions           = Question.pending

    published = Issue.published

    @issue_vote_percentage       = published.flat_map(&:vote_ids).uniq.size * 100 / Vote.count
    @issue_promise_percentage    = published.flat_map(&:promise_ids).uniq.size * 100 / Promise.count
  end
end
