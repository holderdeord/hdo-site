# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  name { "user #{sn}" }
  email { "user#{sn}@email.com" }
  password { "abcd1234" }
  password_confirmation { "abcd1234" }
end

Vote.blueprint do
  external_id { sn.to_s }
  parliament_issues { [ParliamentIssue.make] }
  time { Time.current }
  vote_results { [VoteResult.make!] }
  subject { "vote-subject-#{sn}" }
end

VoteConnection.blueprint do
  issue
  vote
  matches { true }
end

PromiseConnection.blueprint do
  issue
  promise { Promise.make! }
  status { 'related' }
end

VoteResult.blueprint do
  representative { Representative.make!(:full) }
  result { rand(2) - 1 }
end

ParliamentIssue.blueprint do
  external_id { sn.to_s }
  description { "parliament issue #{sn}" }
  status { "behandlet" }
end

Party.blueprint do
  external_id { sn.to_s }
  name { "Party-#{sn}" }
end

Promise.blueprint do
  external_id { sn.to_s }
  parties { [Party.make!] }
  source { "PP:10" }
  body { "Løftetekst-#{sn}" }
  categories { [Category.make!] }
end

Category.blueprint do
  external_id { sn.to_s }
  name { "Category-#{sn}" }
  main { false }
end

Category.blueprint(:with_children) do
  children(2)
end

PartyMembership.blueprint do
  party { Party.make! }
  start_date { 1.month.ago }
  end_date { nil }
end

PartyMembership.blueprint :full do
  representative
end

CommitteeMembership.blueprint do
  committee { Committee.make! }
  start_date { 1.month.ago }
  end_date { nil }
end

CommitteeMembership.blueprint :full do
  representative
end

ParliamentSession.blueprint do
  external_id { "2012-2013-#{sn}" }
  start_date { Date.new(2012, 10, 1) }
  end_date { Date.new(2013, 9, 30) }
end

ParliamentPeriod.blueprint do
  external_id { "2009-2013-#{sn}" }
  start_date { Date.new(2009, 10, 1) }
  end_date { Date.new(2013, 9, 30) }
end

Representative.blueprint do
  external_id { sn.to_s }
  first_name { "first-name-#{sn}" }
  last_name { "last-name-#{sn}" }
end

Representative.blueprint :full do
  party_memberships(1)
end

Representative.blueprint :confirmed do
  external_id  { sn.to_s }
  first_name   { "first-name-#{sn}" }
  last_name    { "last-name-#{sn}" }
  party_memberships(1)
  email        { "#{sn}@email.com" }
  confirmed_at { Time.now }
end

Issue.blueprint do
  title { "issue-title-#{sn}" }
  description { "issue-description-#{sn}" }
  vote_connections {
    Array.new(2) { VoteConnection.make!(:issue => object) }
  }
end

Issue.blueprint :published do
  status { 'published' }
end

Proposition.blueprint do
  external_id { sn.to_s }
  body { "proposition-body-#{sn}" }
  description { "proposition-description-#{sn}" }
end

GoverningPeriod.blueprint do
  party { Party.make! }
  start_date { Date.today }
end

GoverningPeriod.blueprint :full do
end

Committee.blueprint do
  external_id { sn.to_s }
  name { "committee-#{sn}" }
end

District.blueprint do
  external_id { sn.to_s }
  name { "district-#{sn}" }
end

Question.blueprint do
  body { "question body #{sn}" }
  representative { Representative.make! }
  from_name { "Ola Nordmann" }
  from_email { "ola.nordmann@engasjert.no" }
end

Answer.blueprint do
  body { "answer body" }
  representative { Representative.make! }
  question { Question.make! }
end

PartyComment.blueprint do
  body  { 'This is my body' }
  party
  issue
end