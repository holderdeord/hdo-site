# encoding: utf-8

require 'spec_helper'

describe Issue, :search do
  def issue_titled(title)
    issue = Issue.make!(title: title, status: 'published')
    refresh_index

    issue
  end

  it 'finds "formueskatten" for query "skatt"' do
    issue = issue_titled 'fjerne formueskatten'
    results = results_for 'skatt'

    results.should_not be_empty
    results.first.load.should == issue
  end

  it 'does synonym mappings' do
    issue_titled 'miljøvern'
    issue_titled 'klima'

    results_for('miljøvern').size.should == 2
    results_for('klima').size.should == 2
  end

  context 'refresh on association update' do
    it 'updates the index when associated categories change' do
      category = Category.make!
      issue = Issue.make!({status: 'published', categories: [category]})

      refresh_index

      results_for('*').size.should == 1

      result = Issue.search('*').results.first
      result.categories.first.name.should == category.name

      category.update_attributes!(name: 'shrimp')
      refresh_index

      result = Issue.search('*').results.first
      result.categories.first.name.should == category.name
    end

    it 'updates the index when associated topics change' do
      topic = Topic.make!
      Issue.make!(status: 'published', topics: [topic])
      refresh_index

      results_for('*').first.topics.first.name.should == topic.name

      topic.update_attributes!(name: 'clown fish')
      refresh_index

      results_for('*').first.topics.first.name.should == topic.name
    end
  end
end
