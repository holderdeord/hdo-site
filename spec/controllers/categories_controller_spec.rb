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

  it 'renders promises for categories for XHR requests' do
    prom = Promise.make!
    cat_id = prom.categories.first.id

    get :promises, id: cat_id

    response.should be_success
    response.should have_rendered(:promises, layout: true)
  end

  it 'can fetch subcategories' do
    cat = Category.make!(:with_children)

    get :subcategories, id: cat.id

    response.should be_success
    response.content_type.should be_json
  end
end
