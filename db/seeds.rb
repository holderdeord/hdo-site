# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  existing = User.find_by_email("admin@holderdeord.no")
  existing && existing.destroy

  puts "creating development user u=admin@holderdeord.no p=hdo123"

  User.create!(
    name: 'admin',
    email: "admin@holderdeord.no",
    password: "hdo123",
    password_confirmation: "hdo123",
    remember_me: false
  )
end
