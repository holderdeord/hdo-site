require 'spec_helper'

describe Vote do
  def search(query)
    Vote.naive_search(nil, query)
  end

  def es_search(query)
    Vote.search(query).results.load.to_a
  end

  context 'open search' do
    it 'finds votes with processed parliament issues' do
      processed_issue     = ParliamentIssue.make!
      non_processed_issue = ParliamentIssue.make!(status: "motatt")

      v1 = Vote.make!(parliament_issues: [processed_issue, non_processed_issue])
      v2 = Vote.make!(parliament_issues: [processed_issue])
      v3 = Vote.make!(parliament_issues: [non_processed_issue])

      search('').should == [v2]
    end
  end

  context 'keyword search' do
    it 'finds votes where the parliament issue description matches the query' do
      match = Vote.make!(parliament_issues: [ParliamentIssue.make!(description: 'skatt' )])
      miss  = Vote.make!(parliament_issues: [ParliamentIssue.make!(description: 'klima' )])

      search('skatt').should == [match]
    end

    it 'finds votes where the proposition body matches the query' do
      match = Vote.make!(propositions: [Proposition.make!(:body => "<h1>skatt</h1>")])
      miss  = Vote.make!(propositions: [Proposition.make!(:body => "<h1>klima</h1>")])

      search('skatt').should == [match]
    end
  end
end