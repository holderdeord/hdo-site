require 'spec_helper'

describe DistrictsController do
  it 'renders districts#index' do
    District.make!

    get :index
    response.should have_rendered(:index)
  end

  it 'renders categories#show' do
    get :show, id: District.make!
    response.should have_rendered(:show)
  end
end
