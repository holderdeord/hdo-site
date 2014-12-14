require 'spec_helper'

describe PartiesController do
  let(:party) { Party.make! }

  describe "GET #index" do
    it 'populates an array of parties' do
      parties = [party]
      get :index
      assigns(:parties).should == parties
    end

    it 'renders the :index view' do
      get :index
      response.should have_rendered(:index)
    end
  end

  describe "GET #show" do
    before { ParliamentPeriod.make!(start_date: Date.new(2009, 10, 1), end_date: Date.new(2013, 9, 30)) }

    it 'assigns the proposition feed' do
      get :show, id: party

      assigns(:proposition_feed)
    end

    it 'renders the :show template' do
      get :show, id: party
      response.should have_rendered(:show)
    end
  end
end
