require 'spec_helper'

describe CommitteesController do
  it 'renders committees#index' do
    Committee.make!

    get :index
    response.should have_rendered(:index)
  end

  it 'renders committees#show' do
    get :show, id: Committee.make!
    response.should have_rendered(:show)
  end
end
