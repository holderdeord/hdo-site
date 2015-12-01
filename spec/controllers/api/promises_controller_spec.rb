require 'spec_helper'

describe Api::PromisesController, :api do
  it 'can GET :index' do
    Promise.make!

    get :index, format: :hal

    response.should be_success
    json_response['total'].should == 1
    relations.should == %w[filtered find promises self widgets] # TODO: pagination rels
  end

  it 'can GET :show' do
    p = Promise.make!

    get :show, id: p, format: :hal

    response.should be_success
    json_response.keys.should include('source', 'body', 'promisor_name', 'party_names')
    relations.should == %w[parties self widget]
  end
end
