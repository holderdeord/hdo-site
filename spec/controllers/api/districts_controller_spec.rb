require 'spec_helper'

describe Api::DistrictsController, :api do
  it 'can GET :index' do
    get :index, format: :hal

    response.should be_success
    relations.should == %w[districts find self]
  end

  it 'can GET :show' do
    e = District.make!

    get :show, id: e, format: :hal

    response.should be_success
    relations.should == %w[self]
  end
end
