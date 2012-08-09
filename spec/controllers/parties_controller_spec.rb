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
    it 'assigns the requested party to @party' do
      get :show, id: party

      assigns(:party).should == party
    end

    it 'fetches the latest topics' do
      t1 = Topic.make!
      t2 = Topic.make!

      t1.vote_connections.map { |e| e.vote.update_attributes!(:time => 3.days.ago) }
      t2.vote_connections.map { |e| e.vote.update_attributes!(:time => 2.days.ago) }

      get :show, id: party
      assigns(:topics).should == [t2, t1]
    end

    it 'renders the :show template' do
      get :show, id: party
      response.should have_rendered(:show)
    end
  end
end
