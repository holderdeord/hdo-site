# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# temporary topic example
topic = Topic.create!(
  title: "Formueskatt",
  description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
)

topic.promises << Promise.where(:body => "Opprettholde formueskatten, men gjøre den mer rettferdig.", :party_id => Party.find_by_external_id("A")).first
topic.save!

VoteDirection.create!(:vote => Vote.find_by_external_id(2349), :matches => false, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2351), :matches => true, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2350), :matches => false, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2352), :matches => false, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2354), :matches => true, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2353), :matches => false, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2172), :matches => true, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(2171), :matches => false, :topic => topic)
VoteDirection.create!(:vote => Vote.find_by_external_id(1570), :matches => false, :topic => topic)


# User.create!(:email => "admin@holderdeord.no", :password => "hdo123", :password_confirmation => "hdo123", :remember_me => false)
