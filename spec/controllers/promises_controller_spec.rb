require 'spec_helper'

describe PromisesController do
  let(:promise) { Promise.make! }

  describe "GET #index" do

    it 'renders promises#index' do
      get :index
      response.should have_rendered(:index)
    end

    it 'contains all promises in a period by default' do
      promises = [promise]

      get :index, { period: promise.parliament_period.external_id }
      assigns(:promises).should == promises
    end

    it 'contains all promises if period is nil' do
      promises = [promise]

      get :index, { period: nil }
      assigns(:promises).should == promises
    end

    it 'can filter promises by category' do
      category = Category.make!(main: true)
      promise_with_category = Promise.make!(categories: [category])

      get :index, { category_id: category.id, period: promise_with_category.parliament_period.external_id }
      assigns(:promises).should == [promise_with_category]
    end

    it 'filters by category and includes promises in subcategories' do
      period = ParliamentPeriod.make!

      category               = Category.make!(main: true)
      subcategory            = Category.make!(parent: category)

      promise_in_category    = Promise.make!(categories: [category], parliament_period: period)
      promise_in_subcategory = Promise.make!(categories: [subcategory], parliament_period: period)

      get :index, { category_id: category.id, period: promise_in_category.parliament_period.external_id }

      assigns(:promises).should == [promise_in_category, promise_in_subcategory]
    end

    it 'can filter promises by subcategory' do
      category = Category.make!(main: true)
      subcategory = Category.make!(parent: category)
      promise_in_subcategory = Promise.make!(categories: [subcategory])

      get :index, { category_id: category.id, subcategory_id: subcategory.id, period: promise_in_subcategory.parliament_period.external_id }
      assigns(:promises).should == [promise_in_subcategory]
    end

    it 'can filter promises by category and party' do
      party = Party.make!
      category = Category.make!(main: true)
      promise_in_cat_and_party = Promise.make!(categories: [category], parties: [party])

      get :index, { category_id: category.id, party_id: party.id, period: promise_in_cat_and_party.parliament_period.external_id }
      assigns(:promises).should == [promise_in_cat_and_party]
    end

    it 'can filter promises by party' do
      party = Party.make!
      promise_in_party = Promise.make!(parties: [party])

      get :index, { party_id: party.id, period: promise_in_party.parliament_period.external_id }
      assigns(:promises).should == [promise_in_party]
    end

    it 'can filter promises by category and parliament period' do
      period_a = ParliamentPeriod.make!
      period_b = ParliamentPeriod.make!

      category = Category.make!(main: true)

      promises = [
        Promise.make!(parliament_period: period_a, categories: [category]),
        Promise.make!(parliament_period: period_b, categories: [category])
      ]

      get :index, period: period_a.external_id, category_id: category.id

      assigns(:promises).should == [promises.first]
    end
  end

  describe "Get #show" do
    it 'renders promises#show' do
      get :show, id: promise
      response.should have_rendered(:index)
    end

    it 'assigns the requested promise as @promise' do
      get :show, id: promise
      assigns(:promise).should == promise
    end
  end
end
