require 'spec_helper'

describe RepresentativesController do
  describe 'index' do
    it 'can get #index' do
      rep = Representative.make!

      get :index

      response.should have_rendered(:index)
    end

    it 'can get #index_by_name' do
      rep = Representative.make!

      xhr :get, :index_by_name
      response.should be_ok

      assigns(:representatives).should == [rep]
      response.should have_rendered(:index_by_name)
    end

    it 'can get #index_by_party' do
      rep = Representative.make!

      xhr :get, :index_by_party
      response.should be_ok

      assigns(:by_party).should == {rep.current_party => [rep]}
      response.should have_rendered(:index_by_party)
    end

    it 'can get #index_by_district' do
      rep = Representative.make!

      xhr :get, :index_by_district
      response.should be_ok

      assigns(:by_district).should == {rep.district => [rep]}
      response.should have_rendered(:index_by_district)
    end

    it 'fails on non-XHR for index_by_*' do
      expected_status = 406

      get :index_by_name
      response.status.should == expected_status

      get :index_by_party
      response.status.should == expected_status

      get :index_by_district
      response.status.should == expected_status
    end
  end


  describe "GET #show" do
    it 'assigns the requested representative to @representative' do
      rep = Representative.make!

      get :show, id: rep

      assigns(:representative).should == rep
      response.should have_rendered(:show)
    end
  end

end
