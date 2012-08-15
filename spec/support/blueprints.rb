# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  name { "user #{sn}" }
  email { "user#{sn}@email.com}" }
  password { "abcd1234" }
  password_confirmation { "abcd1234" }
end

Vote.blueprint do
  issues { [Issue.make] }
  time { Time.now }
  vote_results { [VoteResult.make!] }
end

VoteConnection.blueprint do
  topic
  vote
  matches { true }
end

VoteResult.blueprint do
  representative { Representative.make! }
  result { rand(2) - 1 }
end

Issue.blueprint do

end

Field.blueprint do
  name { "Field-#{sn}" }
end

Party.blueprint do
  external_id { sn.to_s }
  name { "Party-#{sn}" }
end

Promise.blueprint do
  parties { [Party.make!] }
  source { "PP:10" }
  body { "Løftetekst" }
  categories { [Category.make!] }
end

Category.blueprint do
  name { "Category-#{sn}" }
  main { false }
end

Representative.blueprint do
  external_id { sn.to_s }
  party { Party.make! }
  first_name { "first-name-#{sn}" }
  last_name { "last-name-#{sn}" }
end

Topic.blueprint do
  title { "topic-title-#{sn}" }
  description { "topic-description-#{sn}" }
  vote_connections {
    Array.new(2) { VoteConnection.make!(:topic => object) }
  }
end

Proposition.blueprint do
  body { "proposition-body-#{sn}" }
  description { "proposition-description-#{sn}" }
end

GoverningPeriod.blueprint do
  party { Party.make! }
  start_date { Date.today }
end

Committee.blueprint do
  name { "committee-#{sn}" }
end

District.blueprint do
  name { "committee-#{sn}" }
end