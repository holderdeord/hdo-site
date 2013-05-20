require 'spec_helper'

describe CategoriesController do
  it 'renders categories#index' do
    Category.make!

    get :index
    response.should have_rendered(:index)
  end

  it 'renders categories#show' do
    get :show, id: Category.make!
    response.should have_rendered(:show)
  end
end
