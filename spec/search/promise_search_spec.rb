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
  end
end