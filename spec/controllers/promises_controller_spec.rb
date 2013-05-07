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

    it 'includes promises in subcategory' do
      category = Category.make!(main:true)
      promise_in_category = Promise.make!(categories: [category])
      subcategory = Category.make!(parent: category)
      promise_in_subcategory = Promise.make!(categories: [subcategory])

      get :index, {category_id: category.id}
      assigns(:promises).should == [promise_in_category, promise_in_subcategory]
    end

    it 'can filter promises by party' do
      party = Party.make!
      promise_in_party = Promise.make!(parties: [party])

      get :index, {party_id: party.id}
      assigns(:promises).should == [promise_in_party]
    end

    it 'can filter promises by party and category' do
      party = Party.make!
      category = Category.make!(main:true)
      promise_in_all = Promise.make!(categories: [category], parties: [party])

      get :index, {category_id: category.id, party_id: party.id}
      assigns(:promises).should == [promise_in_all]
    end

    it 'can filter promises by subcategory' do
      category = Category.make!(main:true)
      subcategory = Category.make!(parent: category)
      promise_in_subcategory = Promise.make!(categories: [subcategory])

      get :index, {category_id: category.id, subcategory_id: subcategory.id}
      assigns(:promises).should == [promise_in_subcategory]
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
