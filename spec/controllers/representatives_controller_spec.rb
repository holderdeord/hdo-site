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
    let(:rep) { Representative.make! }

    it 'assigns the requested representative to @representative' do
      get :show, id: rep

      assigns(:representative).should == rep
      response.should have_rendered(:show)
    end

    it 'assigns published issues to @issues' do
      Issue.any_instance.stub(:stats).and_return(mock(score_for: 100, key_for: :for))

      shown     = Issue.make!(status: 'published')
      not_shown = Issue.make!(status: 'in_progress')

      get :show, id: rep

      assigns(:issue_groups).should == {"for" => [shown]}
      response.should have_rendered(:show)
    end

    it 'assigns approved questions to @questions' do
      approved  = Question.make!(representative: rep, status: 'approved')
      pending   = Question.make!(representative: rep, status: 'pending')
      other_rep = Question.make!(representative: Representative.make!, status: 'approved')

      get :show, id: rep

      assigns(:questions).should == [approved]
    end
  end

end
