require 'spec_helper'

describe PropositionEndorsement do
  it 'is unique' do
    rep = Representative.make!
    prop = Proposition.make!

    PropositionEndorsement.create!(:proposer => rep, proposition: prop)
    PropositionEndorsement.create(:proposer => rep, proposition: prop).should_not be_valid
  end
end