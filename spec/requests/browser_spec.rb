require 'spec_helper'
SimpleCov.command_name 'requests'

describe Hdo::Application do
  include BrowserSpecHelper

  it "should load the front page" do
    front_page.get
  end

  it "should show a list of votes" do
    2.times { Vote.make!(:for_count => 50, :against_count => 50, :absent_count => 69) }

    page = votes_page.get
    page.vote_count.should == 2

    vote = page.first_vote

    vote.for.should == "50% (50/100)"
    vote.against.should == "50% (50/100)"
    vote.absent.should == "40% (69/169)"
  end
end
