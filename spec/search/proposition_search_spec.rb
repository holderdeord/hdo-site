require 'spec_helper'

describe Proposition, :search do
  context 'refresh on association update' do
    it 'updates the index when associated votes change' do
      vote = Vote.make!
      prop = Proposition.make!(votes: [vote])

      refresh_index

      Proposition.search('*').results.first.votes.first.slug.should == vote.slug

      vote.update_attributes!(time: Time.now + 1.day)

      refresh_index

      Proposition.search('*').results.first.votes.first.slug.should == vote.slug
    end

    it 'updates the index when associated parliament issues change' do
      vote  = Vote.make!
      issue = ParliamentIssue.make!(votes: [vote], document_group: 'Foo')
      prop  = Proposition.make!(votes: [vote])

      refresh_index
      result = Proposition.search('*').results.first
      result.parliament_issue_document_group_names.should == ['Foo']

      issue.update_attributes!(document_group: 'Bar')

      refresh_index
      result = Proposition.search('*').results.first
      result.parliament_issue_document_group_names.should == ['Bar']
    end
  end

  it 'indexes non-attribute data (no partial update)' do
    prop = Proposition.make!(body: '<p>foo</p>')

    refresh_index
    Proposition.search('*').results.first.plain_body.should == 'foo'

    prop.update_attributes!(body: '<p>bar</p>')

    refresh_index
    Proposition.search('*').results.first.plain_body.should == 'bar'
  end

end