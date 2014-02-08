require 'spec_helper'
require 'models/shared/open_ended_date_range'

describe PartyMembership do
  let(:representative) { Representative.make! }
  let(:party) { Party.make! }

  it_behaves_like Hdo::Model::OpenEndedDateRange

  it 'can not overlap in time for the same representative (open ended)' do
    valid = representative.party_memberships.make!(:start_date => 1.month.ago, :end_date => nil, :party => Party.make!)
    invalid = representative.party_memberships.make(:start_date => 20.days.ago, :end_date => nil, :party => Party.make!)

    invalid.should_not be_valid
  end
end
