require 'spec_helper'

describe Api::PartiesController, :api do
  it 'can GET :index' do
    get :index, format: :hal

    response.should be_success
    relations.should == %w[find parties self]
  end

  it 'can GET :show' do
    pr = Party.make!
    get :show, id: pr, format: :hal

    response.should be_success
    relations.should == %w[attending_representatives logo representatives self]
  end

  it 'can GET :representatives' do
    rep = Representative.make!(:full)

    get :representatives, id: rep.latest_party.id, format: :hal

    response.should be_success
    relations.should == %w[representatives self] # TODO: pagination rels
  end

  it 'can GET :attending_representatives' do
    rep = Representative.make!(:full, attending: true)

    get :representatives, id: rep.current_party.id, attending: true, format: :hal

    response.should be_success
    relations.should == %w[attending_representatives self] # TODO: pagination rels
  end
end
