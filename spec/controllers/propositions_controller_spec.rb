require 'spec_helper'

describe PropositionsController do
  it 'can GET :index' do
    get :index

    response.should be_ok
    response.should have_rendered(:index)
  end

  it 'can GET :show' do
    proposition = Proposition.make!

    get :show, id: proposition

    response.should be_ok
    response.should have_rendered(:show)
  end

  it 'renders promises#index as csv' do
    get :index, format: :csv
    response.should be_success
  end

  it 'renders promises#index as tsv' do
    get :index, format: :tsv
    response.should be_success
  end
end
