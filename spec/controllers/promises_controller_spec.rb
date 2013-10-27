require 'spec_helper'

describe PromisesController do
  let(:promise) { Promise.make! }

  describe "GET #index" do

    it 'renders promises#index' do
      get :index
      response.should have_rendered(:index)
    end

    it 'contains all promises in a period by default' do
      promise_a = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2009-10-01'))
      promise_b = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2013-10-01'))

      get :index, { period: promise_a.parliament_period.external_id }
      assigns(:promises).should == [promise_a]

      get :index, { period: promise_b.parliament_period.external_id }
      assigns(:promises).should == [promise_b]
    end

    it 'selects the latest period if period is nil' do
      promise_a = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2009-10-01'))
      promise_b = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2013-10-01'))

      get :index, { period: nil }
      assigns(:promises).should == [promise_b]
    end

    it 'can filter promises by category' do
      category = Category.make!(main: true)

      expected_promise = Promise.make!(categories: [category])
      other_promise = Promise.make!(categories: [Category.make!])

      get :index, { category_id: category.id }
      assigns(:promises).should == [expected_promise]
    end

    it 'filters by category and subcategories' do
      period = ParliamentPeriod.make!

      category               = Category.make!(main: true)
      subcategory            = Category.make!(parent: category)

      promise_in_category    = Promise.make!(categories: [category], parliament_period: period)
      promise_in_subcategory = Promise.make!(categories: [subcategory], parliament_period: period)

      get :index, { category_id: category.id, period: promise_in_category.parliament_period.external_id }

      assigns(:promises).should == [promise_in_category, promise_in_subcategory]
    end

    it 'can filter promises by subcategory' do
      category          = Category.make!(main: true)
      subcategory       = Category.make!(parent: category)
      other_subcategory = Category.make!(parent: category)

      promise_in_subcategory       = Promise.make!(categories: [subcategory])
      promise_in_other_subcategory = Promise.make!(categories: [other_subcategory])

      get :index, { category_id: category.id, subcategory_id: subcategory.id }
      assigns(:promises).should == [promise_in_subcategory]
    end

    it 'can filter promises by category and party promisor' do
      party    = Party.make!
      category = Category.make!(main: true)

      promise_in_cat_and_party       = Promise.make!(categories: [category], promisor: party)
      promise_in_cat_and_other_party = Promise.make!(categories: [category], promisor: Party.make!)

      get :index, { category_id: category.id, promisor: [party.id, party.class.name].join(':') }
      assigns(:promises).should == [promise_in_cat_and_party]
    end

    it 'can filter promises by party promisor' do
      party = Party.make!

      party_promise     = Promise.make!(promisor: party)
      non_party_promise = Promise.make!(promisor: Party.make!)

      get :index, { promisor: [party.id, party.class.name].join(':') }
      assigns(:promises).should == [party_promise]
    end

    it 'can filter promises by government promisor' do
      party = Party.make!

      gov = Government.make!(:parties => [party])

      government_promise = Promise.make!(promisor: gov)
      party_promise      = Promise.make!(promisor: party)

      get :index, { promisor: [gov.id, gov.class.name].join(':') }
      assigns(:promises).should == [government_promise]
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
