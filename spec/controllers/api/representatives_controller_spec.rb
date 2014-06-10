require 'spec_helper'

describe Api::RepresentativesController, :api do
  it 'can GET :index' do
    get :index, format: :hal

    response.should be_success
    relations.should == %w[find representatives self] # TODO: pagination rels
  end

  it 'can GET :show' do
    rep = Representative.make!(:full)

    get :show, id: rep, format: :hal

    response.should be_success
    relations.should == %w[committees district image party self]
  end

  it "returns :not_found if the representative doesn't exist" do
    get :show, id: 'foobar', format: :hal

    response.should be_not_found
  end

end
