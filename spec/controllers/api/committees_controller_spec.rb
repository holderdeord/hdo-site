require 'spec_helper'

describe Api::CommitteesController, :api do
  it 'can GET :index' do
    get :index, format: :hal

    response.should be_success
    relations.should == %w[committees find self]
  end

  it 'can GET :show' do
    e = Committee.make!

    get :show, id: e, format: :hal

    response.should be_success
    relations.should == %w[representatives self]
  end
end
