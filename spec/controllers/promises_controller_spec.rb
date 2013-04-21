require 'spec_helper'

describe PromisesController do
  let(:promise) { Promise.make! }

  describe "GET #index" do 
    it 'renders promises#index' do
      get :index
      response.should have_rendered(:index)
    end

    it 'contains all promises by default' do
      promises = [promise]

      get :index
      assigns(:promises).should == promises
    end

    it 'can filter promises by category' do
      category = Category.make!(main: true)
      promise_with_category = Promise.make!(categories: [category])

      get :index, {category_id: category.id}
      assigns(:promises).should == [promise_with_category]
    end
  end

  describe "Get #show" do
    it 'renders promises#show' do
      get :show, id: promise
      response.should have_rendered(:show)
    end

    it 'assigns the requested promise as @promise' do
      get :show, id: promise
      assigns(:promise).should == promise
    end
  end
end
