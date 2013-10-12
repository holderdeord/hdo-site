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
    let(:rep) { Representative.make! :confirmed }

    it 'assigns the requested representative to @representative' do
      get :show, id: rep

      assigns(:representative).should == rep
      response.should have_rendered(:show)
    end

    it 'assigns approved questions to @questions' do
      approved  = Question.make!(representative: rep, status: 'approved')
      pending   = Question.make!(representative: rep, status: 'pending')
      other_rep = Question.make!(representative: Representative.make!(:confirmed), status: 'approved')

      get :show, id: rep

      assigns(:questions).should == [approved]
    end

    it 'sorts the questions by answer creation, then question creation' do
      q1 = Question.make!(representative: rep, status: 'approved')
      q1.create_answer!(body: 'foo', representative: rep, status: 'approved')


      q2 = Question.make!(representative: rep, status: 'approved')
      q2.create_answer!(body: 'bar', representative: rep, status: 'approved')

      q3 = Question.make!(representative: rep, status: 'approved')

      q1.created_at        = 20.days.ago
      q1.answer.created_at = 6.days.ago

      q2.created_at        = 10.days.ago
      q2.answer.created_at = 9.days.ago

      q3.created_at = 5.days.ago

      [q1, q2, q3].map { |e| e.answer.try(:save!); e.save! }

      get :show, id: rep
      assigns(:questions).should == [q3, q1, q2]
    end
  end

end
