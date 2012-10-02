require 'spec_helper'
require 'models/shared_examples_for_model_with_date_range'

describe PartyMembership do
  let(:representative) { Representative.make!(:party_memberships => [])}
  let(:party) { Party.make! }

  it_behaves_like 'model with date range'

  it 'can not overlap in time for the same representative (open ended)' do
    valid = representative.party_memberships.make!(:start_date => 1.month.ago, :end_date => nil, :party => Party.make!)
    invalid = representative.party_memberships.make(:start_date => 20.days.ago, :end_date => nil, :party => Party.make!)

    invalid.should_not be_valid
  end
end
