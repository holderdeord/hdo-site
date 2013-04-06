require 'spec_helper'
SimpleCov.command_name 'requests'

describe Hdo::Application do
  it "should load the front page" do
    front_page.get
  end

  it 'autocompletes a search for issues' do
    Issue.create!(status: "published", title: "Fjerne formueskatten")
    Issue.index.refresh

    menu = front_page.get.menu
    menu.search_for('skatt')

    wait(10).until { menu.autocomplete_results.any? }

    menu.autocomplete_results.first.title.should == "Fjerne formueskatten"
  end
end
