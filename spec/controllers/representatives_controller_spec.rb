require 'spec_helper'

describe RepresentativesController do

  describe "GET #show" do
    it 'assigns the requested representative to @representative' do
      rep = Representative.make!

      get :show, id: rep
      assigns(:representative).should == rep
    end

    it 'renders the #show template' do
      get :show, id: Representative.make!
      response.should render_template(:show)
    end
  end

end
