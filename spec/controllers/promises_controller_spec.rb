require 'spec_helper'

describe PromisesController do
  include SearchSpecHelper

  let(:promise) { Promise.make! }

  def elasticsearch
    Promise.__elasticsearch__
  end

  def refresh
    refresh_index
  end

  def results
    assigns(:search).records.to_a
  end

  describe "GET #index" do

    xit 'renders promises#index' do
      get :index
      response.should have_rendered(:index)
    end

    it 'renders promises#index as csv' do
      get :index, format: :csv
      response.should be_success
    end

    it 'renders promises#index as tsv' do
      get :index, format: :tsv
      response.should be_success
    end

    xit 'contains all promises in a period by default' do
      promise_a = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2009-10-01'))
      promise_b = Promise.make!(parliament_period: ParliamentPeriod.make!(start_date: '2013-10-01'))

      refresh

      get :index, parliament_period: promise_a.parliament_period.name
      results.should == [promise_a]

      get :index, parliament_period: promise_b.parliament_period.name
      results.should == [promise_b]
    end

    it 'can filter promises by category' do
      category = Category.make!(main: true)

      expected_promise = Promise.make!(categories: [category])
      other_promise = Promise.make!(categories: [Category.make!])

      refresh

      get :index, { category: category.human_name }

      results.should == [expected_promise]
    end

    it 'can filter promises by category and party promisor' do
      party    = Party.make!
      category = Category.make!(main: true)

      promise_in_cat_and_party       = Promise.make!(categories: [category], promisor: party)
      promise_in_cat_and_other_party = Promise.make!(categories: [category], promisor: Party.make!)

      refresh

      get :index, category: category.human_name, promisor: party.name

      results.should == [promise_in_cat_and_party]
    end

    it 'can filter promises by party promisor' do
      party = Party.make!

      party_promise     = Promise.make!(promisor: party)
      non_party_promise = Promise.make!(promisor: Party.make!)

      refresh

      get :index, promisor: party.name

      results.should == [party_promise]
    end

    it 'can filter promises by government promisor' do
      party = Party.make!

      gov = Government.make!(:parties => [party])

      government_promise = Promise.make!(promisor: gov)
      party_promise      = Promise.make!(promisor: party)

      refresh

      get :index, promisor: government_promise.promisor_name

      results.should == [government_promise]
    end

    it 'can filter promises by category and parliament period' do
      period_a = ParliamentPeriod.make!(start_date: '2005-10-01')
      period_b = ParliamentPeriod.make!(start_date: '2009-10-01')

      category = Category.make!(main: true)

      promises = [
        Promise.make!(parliament_period: period_a, categories: [category]),
        Promise.make!(parliament_period: period_b, categories: [category])
      ]

      refresh

      get :index, parliament_period: period_a.name, category: category.human_name

      results.should == [promises.first]
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
