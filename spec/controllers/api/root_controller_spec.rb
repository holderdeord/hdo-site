require 'spec_helper'

describe Api::RootController, :api do
  it 'can get the root' do
    get :index, format: :hal

    response.should be_success
    relations.should == %w[
      self
      license
      issues
      representatives
      parties
      committees
      districts
      promises
      votes
    ].sort
  end
end
