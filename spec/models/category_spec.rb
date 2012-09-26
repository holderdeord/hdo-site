# encoding: utf-8

require 'spec_helper'

describe Category do
  let(:valid_category) { Category.make! }

  it "should have unique names" do
    valid = Category.create!(:name => "foo")
    invalid = Category.create(:name => "foo")

    invalid.should_not be_valid
  end

  it 'should group into columns by children size' do
    mains = Array.new(10) { |n| Category.make!(:name => "main-#{n}", :main => true) }

    subcategory_counts = [2, 5, 11, 3, 4, 6, 3, 8, 5, 10]
    subcategory_counts.each_with_index do |count, index|
      mains[index].children = Array.new(count) { |n| Category.make!(:name => "sub-#{index}-#{n}", :main => false) }
    end

    groups = Category.column_groups
    groups.size.should == 3

    sums = groups.map do |categories|
      categories.map { |e| e.children.size }.sum
    end

    sums.should == [18, 16, 23]
    sums.sum.should == Category.where(:main => false).count
  end

  it 'correctly creates a human name for categories with non-ASCII characters' do
    category = Category.create(:name => "SJØFART")
    category.human_name.should == "Sjøfart"
  end

  it 'only uppercases the first letter if category name contains more than one word' do
    category = Category.create(:name => "PRISER OG REGLER")
    category.human_name.should == "Priser og regler"
  end

  it 'keeps EFTA/EU in upper case' do
    category = Category.create(:name => "EFTA/EU")
    category.human_name.should == "EFTA/EU"
  end

  it 'can add parliament issues' do
    p1 = ParliamentIssue.make!
    p2 = ParliamentIssue.make!

    valid_category.parliament_issues << p1
    valid_category.parliament_issues << p2

    valid_category.parliament_issues.size.should == 2
    valid_category.should be_valid
  end

  it "won't add the same parliament issue twice" do
    pi = ParliamentIssue.make!

    valid_category.parliament_issues << pi
    valid_category.parliament_issues << pi

    valid_category.parliament_issues.size.should == 1
  end

  it 'can add promises' do
    promise = Promise.make!

    valid_category.promises << promise
    valid_category.promises.size.should == 1
  end

  it "won't add the same promise twice" do
    promise = Promise.make!

    valid_category.promises << promise
    valid_category.promises << promise

    valid_category.promises.size.should == 1
  end

  it 'can add issues' do
    issue = Issue.make!

    valid_category.issues << issue
    valid_category.issues.size.should == 1
  end

  it "won't add the same issue twice" do
    issue = Issue.make!

    valid_category.issues << issue
    valid_category.issues << issue

    valid_category.issues.size.should == 1
  end
end
