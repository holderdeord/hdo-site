module Admin::IssuesHelper
  def connected_issues_for(vote)
    (vote.issues - [@issue]).first(3)
  end
end