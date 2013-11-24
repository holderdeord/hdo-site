require 'spec_helper'

describe Admin::IssuesHelper do
  it 'should create options for proposition types' do
    opts = proposition_type_options_for(PropositionConnection.make!(proposition_type: 'parliamentary_report'))

    opts.should be_kind_of(String)
    opts.should_not be_empty
  end
end
