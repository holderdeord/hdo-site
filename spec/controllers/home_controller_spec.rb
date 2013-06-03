require 'spec_helper'

describe HomeController do
  context 'issues' do
    it 'loads only published issues' do
      issues = []

      issues << Issue.make!(status: 'published')
      issues << Issue.make!(status: 'in_progress')
      issues << Issue.make!(status: 'published')
      issues << Issue.make!(status: 'published')

      issues.first.tap do |i|
        i.tag_list << "foo"
        i.save!
      end

      get :index

      assigns(:issues).each do |issue|
        issue.should be_published
      end

      assigns(:all_tags).map(&:name).should == ["foo"]
      assigns(:leaderboard).should be_kind_of(Hdo::Stats::Leaderboard)
    end
  end

  it 'disallows robots in non-production environments' do
    get :robots

    body = response.body
    body.should include("User-Agent: *")
    body.should include("Disallow: /")
  end

  context 'with rendered views' do
    render_views

    it 'renders home#index' do
      get :index

      response.should have_rendered(:index)
    end
  end

  context 'blog' do
    it 'shows only the newest blog post'
    it 'shows links to the last three posts'
  end
end