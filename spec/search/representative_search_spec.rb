# encoding: utf-8

require 'spec_helper'

describe Representative, :search do
  it 'finds the representative when searching by party' do
    rep = Representative.make!
    PartyMembership.make!(:party => Party.make!(:name => "foobar"), :representative => rep)
    rep.save!

    refresh_index

    found = Representative.search(rep.latest_party.name).results.first
    found.should_not be_nil

    found = Representative.search(rep.latest_party.external_id).results.first
    found.should_not be_nil
  end

  it 'finds the representative when searching by district' do
    rep = Representative.make!(:district => District.make!(:name => "Akershus"))

    refresh_index

    found = Representative.search("akershus").results.first
    found.should_not be_nil
  end

  context 'refresh on association update' do
    it 'updates the index when associated district changes' do
      district = District.make!
      rep = Representative.make!(district: district)

      refresh_index

      Representative.search('*').results.first.district.name.should == district.name

      district.update_attributes!(name: 'Mordor')
      refresh_index

      Representative.search('*').results.first.district.name.should == district.name
    end

    it 'updates the index when latest party changes' do
      party = Party.make!
      rep = Representative.make!
      rep.party_memberships.create(:party => party, :start_date => 2.months.ago)
      rep.save!

      refresh_index

      Representative.search('*').results.first.latest_party.name.should == party.name

      party.update_attributes!(name: 'bachelors party')

      refresh_index

      Representative.search('*').results.first.latest_party.name.should == party.name
    end

    it 'updates the index when party membership changes' do
      party_before = Party.make!
      party_after  = Party.make!
      rep          = Representative.make!

      rep.party_memberships.create!(party: party_before, start_date: 2.months.ago)

      refresh_index

      Representative.search('*').results.first.latest_party.name.should == party_before.name

      party_membership = rep.party_memberships.first
      party_membership.update_attributes!(party: party_after)

      refresh_index

      Representative.search('*').results.first.latest_party.name.should == party_after.name
    end
  end
end