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
  vote_results { Array.new(10) { VoteResult.make! } }
end

VoteDirection.blueprint do
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

Party.blueprint do
  name { "Party-#{sn}" }
end

Promise.blueprint do
  party
  source { "PP:10" }
  body { "Løftetekst" }
end

Category.blueprint do
  name { "Category-#{sn}" }
  main { false }
end

Representative.blueprint do
  party { Party.make! }
  first_name { "first-name-#{sn}" }
  last_name { "last-name-#{sn}" }
end

Topic.blueprint do
  title { "topic-title-#{sn}" }
  description { "topic-description-#{sn}" }
  vote_directions {
    Array.new(2) { VoteDirection.make!(:topic => object) }
  }
end