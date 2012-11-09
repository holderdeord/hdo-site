# encoding: UTF-8

module IssuesHelper
  def issues_for_promise(issue, promise)
    issues = promise.issues.where("issues.id != ?", issue.id)

    out = ''

    if issues.any?
      out = 'Løftet brukes i '
      out << issues.map { |i| link_to(i.title, i, target: '_blank') }.to_sentence
    end

    out.html_safe
  end
end
