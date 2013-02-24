# encoding: utf-8

require 'spec_helper'

describe Proposition, :search do
  context 'refresh on association update' do
    it 'updates the index when associated votes change' do
      vote = Vote.make!
      Proposition.make!(votes: [vote])
      refresh_index

      Proposition.search('*').results.first.votes.first.slug.should == vote.slug

      vote.update_attributes!(time: Time.now + 1.day)
      refresh_index

      Proposition.search('*').results.first.votes.first.slug.should == vote.slug
    end
  end
end