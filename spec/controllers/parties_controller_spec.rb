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

    it 'fetches published issues' do
      t1 = Issue.make! status: 'published',   title: 'a'
      t2 = Issue.make! status: 'published',   title: 'b'
      t3 = Issue.make! status: 'in_progress', title: 'c'
      t4 = Issue.make! status: 'in_review',   title: 'd'

      t1.proposition_connections.map { |e| e.vote.update_attributes!(time: 4.days.ago) }
      t2.proposition_connections.map { |e| e.vote.update_attributes!(time: 3.days.ago) }
      t3.proposition_connections.map { |e| e.vote.update_attributes!(time: 2.days.ago) }
      t3.proposition_connections.map { |e| e.vote.update_attributes!(time: 1.day.ago) }

      stats = mock(score_for: 100, key_for: :for)
      Issue.any_instance.stub(stats: stats)

      get :show, id: party

      assigns(:issue_groups).should == {'no_promises' => [t1, t2]}
    end

    it 'renders the :show template' do
      get :show, id: party
      response.should have_rendered(:show)
    end
  end
end
