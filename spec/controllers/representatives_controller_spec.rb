require 'spec_helper'

describe RepresentativesController do
  describe 'index' do
    it 'can get #index' do
      rep = Representative.make!

      get :index

      response.should have_rendered(:index)
    end
  end


  describe "GET #show" do
    it 'assigns the requested representative to @representative' do
      rep = Representative.make!

      get :show, id: rep

      assigns(:representative).should == rep
      response.should have_rendered(:show)
    end

    it 'assigns published issues to @issues' do
      Issue.any_instance.stub(:stats).and_return(mock(score_for: 100))

      rep       = Representative.make!
      shown     = Issue.make!(status: 'published')
      not_shown = Issue.make!(status: 'in_progress')

      get :show, id: rep

      assigns(:issues).should == [shown]
      response.should have_rendered(:show)
    end
  end

end
