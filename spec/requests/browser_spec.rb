require 'spec_helper'
SimpleCov.command_name 'requests'

describe Hdo::Application do
  it "should load the front page" do
    front_page.get
  end

  it 'autocompletes a search for issues' do
    issue = Issue.create!(status: "published", title: "Fjerne formueskatten")
    Issue.__elasticsearch__.refresh_index!

    menu = front_page.get.menu
    menu.search_for('skatt')

    result = wait(10).until { menu.autocomplete_results.first }
    result.title.should == "Fjerne formueskatten"
  end
end
