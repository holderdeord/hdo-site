require 'spec_helper'

describe HomeController do
  context 'issues' do
    it 'loads only published issues' do
      issues = []

      issues << Issue.make!(status: 'published')
      issues << Issue.make!(status: 'shelved')
      issues << Issue.make!(status: 'published')
      issues << Issue.make!(status: 'published')

      issues.each do |i|
        i.tag_list << 'foo'
        i.save!
      end

      get :index

      group = assigns(:tag_groups).first

      group.first.name.should == "foo"
      group.last.each do |issue|
        issue.should be_published
      end

      assigns(:all_tags).map(&:name).should == ["foo"]
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
end