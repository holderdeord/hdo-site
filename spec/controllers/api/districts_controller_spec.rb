require 'spec_helper'

describe Api::DistrictsController do
  it 'can GET :index' do
    get :index, format: :hal
    response.should be_success
  end

  it 'can GET :show' do
    e = District.make!
    get :show, id: e, format: :hal

    response.should be_success
  end
end
