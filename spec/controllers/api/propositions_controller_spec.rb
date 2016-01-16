require 'spec_helper'

describe Api::PropositionsController, :api do
  it 'can GET :index' do
    Proposition.make!

    get :index, format: :hal

    response.should be_success
    json_response['total'].should == 1
    relations.should == %w[find propositions self]
  end

  it 'can GET :show' do
    p = Proposition.make!

    get :show, id: p, format: :hal

    response.should be_success
    json_response.keys.should include("title", "body")
    relations.should == %w[proposers self]
  end
end
