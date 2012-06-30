require 'spec_helper'

describe Topic do
  let(:topic) { Topic.new }
  
  it "is invalid without a title" do
    topic.should_not be_valid
    topic.title = "foo"
    topic.should be_valid
  end

  it "can have multiple categories" do
    a = Category.create!(name: "Skole")
    b = Category.create!(name: "Forsvar")

    topic.categories << a
    topic.categories << b

    topic.categories.map(&:name).should == ["Skole", "Forsvar"]
  end

  it "can have multiple promises" do
    topic.promises << Promise.create!(party: Party.new, source: 'PP:10', body: 'hei')
    topic.promises.first.body.should == 'hei'
  end
end
