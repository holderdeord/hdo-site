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
  User.create!(:email => "admin@holderdeord.no", :password => "hdo123", :password_confirmation => "hdo123", :remember_me => false)
end

Topic.destroy_all

puts "creating topics"
[
  "Offentlig forvaltning",
  "Familie",
  "Trossamfunn",
  "Kultur og frivillighet",
  "Helse- og sosialvesen",
  "Utenriks og forsvar",
  "Politi og rettsvesen",
  "Utdanning og forskning",
  "Landbruk og fiskeri",
  "Energi",
  "Miljøvern",
  "Finanser og skatter",
  "Næringsliv",
  "Arbeidsliv",
  "Transport og kommunikasjon"
].each do |topic_name|
  puts "\t#{topic_name}"
  Topic.create! name: topic_name
end
