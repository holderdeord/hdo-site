require 'spec_helper'

describe Api::RepresentativesController do
  it 'can GET :index' do
    get :index, format: :hal
    response.should be_success
  end

  it 'can GET :show' do
    rep = Representative.make!(:full)
    get :show, id: rep, format: :hal

    response.should be_success
  end
end
