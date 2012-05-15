require 'spec_helper'
require 'large/spec_helper'

describe "Front page" do
  it "should load the front page" do
    Pages::FrontPage.new(driver).get
  end
end