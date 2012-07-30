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
      response.should render_template(:index)
    end
  end

  describe "GET #show" do
    it 'assigns the requested party to @party' do
      get :show, id: party
      assigns(:party).should == party
    end
    
    it 'renders the :show template' do
      get :show, id: party
      response.should render_template(:show)
    end
  end
  
  

end
