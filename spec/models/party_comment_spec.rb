require 'spec_helper'

describe PartyComment do
  it "has a valid blueprint" do
    PartyComment.make!.valid?
  end
end
