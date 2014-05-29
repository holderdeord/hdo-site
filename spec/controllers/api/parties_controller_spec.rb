require 'spec_helper'

describe Api::PartiesController do
  it 'can GET :index' do
    get :index, format: :hal
    response.should be_success
  end

  it 'can GET :show' do
    pr = Party.make!
    get :show, id: pr, format: :hal

    response.should be_success
  end

  it 'can GET :representatives' do
    rep = Representative.make!(:full)

    get :representatives, id: rep.latest_party.id, format: :hal

    response.should be_success
  end
end
