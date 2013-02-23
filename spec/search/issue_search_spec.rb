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

  it 'indexes tags' do
    issue = issue_titled 'foo'
    issue.tag_list << 'bar'
    issue.save!

    refresh_index

    results = results_for('bar')
    results.size.should == 1
    results.first.load.should == issue
  end
end