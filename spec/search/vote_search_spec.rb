require 'spec_helper'

describe Vote, :search do
  def es_search(filter, query, categories = [])
    Vote.admin_search(filter, query, categories)
  end

  context 'open search' do
    it 'finds votes with processed parliament issues' do
      processed_issue     = ParliamentIssue.make!
      non_processed_issue = ParliamentIssue.make!(status: "motatt")

      v1 = Vote.make!(parliament_issues: [processed_issue, non_processed_issue])
      v2 = Vote.make!(parliament_issues: [processed_issue])
      v3 = Vote.make!(parliament_issues: [non_processed_issue])

      refresh_index

      es_search(nil, '').should == [v2]
    end
  end

  context 'keyword search' do
    it 'finds votes where the parliament issue description matches the query' do
      match = Vote.make!(parliament_issues: [ParliamentIssue.make!(description: 'skatt')])
      miss  = Vote.make!(parliament_issues: [ParliamentIssue.make!(description: 'klima')])

      refresh_index

      es_search(nil, 'skatt').should == [match]
    end

    it 'finds votes where the proposition body matches the query' do
      match = Vote.make!(propositions: [Proposition.make!(:body => "<h1>skatt</h1>")])
      miss  = Vote.make!(propositions: [Proposition.make!(:body => "<h1>klima</h1>")])

      refresh_index

      es_search(nil, 'skatt').should == [match]
    end

    it 'finds votes where the parliament issue external id matches the query' do
      match = Vote.make!(:parliament_issues => [ParliamentIssue.make!(:external_id => "541232")])
      refresh_index

      es_search(nil, '541232').should == [match]
    end
  end

  context 'category filter' do
    it 'filters by selected categories' do
      first_category  = Category.make!(name: 'klima')
      second_category = Category.make!(name: 'skatt')

      parliament_issue_match = ParliamentIssue.make!(categories: [first_category])
      parliament_issue_miss  = ParliamentIssue.make!(categories: [second_category])

      match = Vote.make!(parliament_issues: [parliament_issue_match])
      miss  = Vote.make!(parliament_issues: [parliament_issue_miss])

      refresh_index

      results = es_search('selected-categories', nil, [first_category])
      results.size.should == 1
      results.first.should == match
    end
  end

  context 'refresh on association update' do
    it 'updates the index when associated propositions change' do
      prop = Proposition.make!
      Vote.make!(propositions: [prop])

      refresh_index

      result = Vote.search('*').results.first
      result.propositions.first.plain_body.should == prop.plain_body

      prop.update_attributes!(body: 'changed body')
      refresh_index

      result = Vote.search('*').results.first

      result.propositions.first.plain_body.should == prop.plain_body
    end

    it 'updates the index when associated parliament issues change' do
      issue = ParliamentIssue.make!
      Vote.make!(parliament_issues: [issue])
      refresh_index

      result = Vote.search('*').results.first
      result.parliament_issues.first.description.should == issue.description

      issue.update_attributes!(description: 'this is a re-indexing issue')
      refresh_index

      result = Vote.search('*').results.first
      result.parliament_issues.first.description.should == issue.description
    end

    it 'updates the index when associated categories change (through parliament issues)' do
      category = Category.make!
      issue    = ParliamentIssue.make!(categories: [category])
      Vote.make!(parliament_issues: [issue])
      refresh_index

      result = Vote.search('*').results.first
      result.category_names.first.should == category.name

      category = Category.make!
      issue.categories = [category]
      issue.save!
      refresh_index

      result = Vote.search('*').results.first
      result.category_names.first.should == category.name
    end
  end

end
