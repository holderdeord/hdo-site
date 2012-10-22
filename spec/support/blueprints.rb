# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  name { "user #{sn}" }
  email { "user#{sn}@email.com}" }
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

VoteResult.blueprint do
  representative { Representative.make!(:full) }
  result { rand(2) - 1 }
end

ParliamentIssue.blueprint do
  external_id { sn.to_s }
end

Topic.blueprint do
  name { "Topic-#{sn}" }
end

Party.blueprint do
  external_id { sn.to_s }
  name { "Party-#{sn}" }
end

Promise.blueprint do
  external_id { sn.to_s }
  parties { [Party.make!] }
  source { "PP:10" }
  body { "Løftetekst" }
  categories { [Category.make!] }
end

Category.blueprint do
  external_id { sn.to_s }
  name { "Category-#{sn}" }
  main { false }
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

Representative.blueprint do
  external_id { sn.to_s }
  first_name { "first-name-#{sn}" }
  last_name { "last-name-#{sn}" }
end

Representative.blueprint :full do
  party_memberships(1)
end

Issue.blueprint do
  title { "issue-title-#{sn}" }
  description { "issue-description-#{sn}" }
  vote_connections {
    Array.new(2) { VoteConnection.make!(:issue => object) }
  }
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
  name { "committee-#{sn}" }
end