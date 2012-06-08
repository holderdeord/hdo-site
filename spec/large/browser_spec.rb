require 'spec_helper'
require 'large/spec_helper'

describe "Site" do
  it "should load the front page" do
    front_page.get
  end

  it "should show the list of representatives" do
    pending
  end

  it "should show a specific representative" do
    pending
  end

  it "should show a list of votes" do
    # TODO: use machinist, factory_girl?
    Vote.create! :for_count     => 50,
                 :against_count => 50,
                 :absent_count  => 69,
                 :subject       => "some subject",
                 :issues        => [Issue.create!],
                 :time          => 2.weeks.ago

    page = votes_page.get
    page.vote_count.should > 0

    vote = page.first_vote

    vote.for.should == "50% (50/100)"
    vote.against.should == "50% (50/100)"
    vote.absent.should == "40% (69/169)"
  end

  it "should show a specific vote" do
    pending
  end
end