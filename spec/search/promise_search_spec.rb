# encoding: utf-8

require 'spec_helper'

describe Promise, :search do
  context 'refresh on association update' do
    it 'updates the index when associated parties change' do
      party = Party.make!
      promise = Promise.make!(promisor: party)

      refresh_index

      Promise.search('*').results.first.party_names.should == [party.name]

      party.update_attributes!(name: 'before part b')
      refresh_index

      Promise.search('*').results.first.party_names.should == [party.name]
    end

    it 'updates the index when associated promise connections change' do
      prom  = Promise.make!
      issue = Issue.make!(promise_connections: [])
      pconn = issue.promise_connections.create!(promise: prom, status: 'related')

      refresh_index
      results = Promise.search('*').results
      results.size.should == 1
      results.first.issue_ids.should == prom.issue_ids

      pconn.destroy

      refresh_index
      result = Promise.search('*').results.first
      result.issue_ids.should == prom.reload.issue_ids
    end

  end

  it 'indexes non-attribute data (no partial update)' do
    promise = Promise.make!

    promise.promisor = Party.make!
    promise.save!

    refresh_index
    Promise.search('*').results.first.promisor_name.should == promise.promisor.name

    promise.promisor = Party.make!
    promise.save!

    refresh_index
    Promise.search('*').results.first.promisor_name.should == promise.promisor.name
  end

end
