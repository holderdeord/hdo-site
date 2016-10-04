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

Vote.blueprint(:with_proposition) do
  propositions { [Proposition.make!]}
end

PropositionConnection.blueprint do
  issue
  proposition { Proposition.make!(:votes => [Vote.make!])}
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
  promisor { Party.make! }
  source { "PP:10" }
  body { "Løftetekst-#{sn}" }
  categories { [Category.make!(main: true)] }
  parliament_period do
    ParliamentPeriod.find_by_external_id('2009-2013') || ParliamentPeriod.make!(external_id: '2009-2013')
  end
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

ParliamentSession.blueprint(:current) do # TODO: fixme
  external_id { "2013-2014" }
  start_date { Date.new(2016, 10, 1) }
  end_date { Date.new(2017, 9, 30) }
end

ParliamentPeriod.blueprint do
  external_id { "2009-2013-#{sn}" }
  start_date { Date.new(2009, 10, 1) }
  end_date { Date.new(2013, 9, 30) }
end

ParliamentPeriod.blueprint(:current) do # TODO: fixme
  external_id { "2013-2017" }
  start_date { Date.new(2013, 10, 1) }
  end_date { Date.new(2017, 9, 30) }
end

Representative.blueprint do
  external_id { sn.to_s }
  first_name { "first-name-#{sn}" }
  last_name { "last-name-#{sn}" }
end

Representative.blueprint :full do
  party_memberships(1)
  district
end

Representative.blueprint :attending do
  attending { true }
  email     { "rep-#{sn}@stortinget.no" }
end

Representative.blueprint :with_email do
  email { "#{sn}@email.com" }
end

Representative.blueprint :confirmed do
  attending    { true }
  external_id  { sn.to_s }
  first_name   { "first-name-#{sn}" }
  last_name    { "last-name-#{sn}" }
  party_memberships(1)
  district
  email        { "#{sn}@email.com" }
  confirmed_at { Time.now }
end

Issue.blueprint do
  title { "issue-title-#{sn}" }
  description { "issue-description-#{sn}" }
  proposition_connections {
    Array.new(2) { PropositionConnection.make!(issue: object) }
  }
  frontpage { false }
end

Issue.blueprint :published do
  status { 'published' }
end

Proposition.blueprint do
  external_id { sn.to_s }
  body { "proposition-body-#{sn}" }
  description { "proposition-description-#{sn}" }
end

Proposition.blueprint :with_vote do
  votes { [Vote.make!] }
end

Government.blueprint do
  name { "government-#{sn}" }
  start_date { Date.today }
end

Government.blueprint :full do
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
  representative { Representative.make!(:confirmed) }
  from_name { "Ola Nordmann" }
  from_email { "ola.nordmann@engasjert.no" }
end

Question.blueprint :approved do
  status { "approved" }
end

Question.blueprint :rejected do
  status { "rejected" }
end

Question.blueprint :finally_rejected do
  status { "finally_rejected" }
end

Answer.blueprint do
  body { "answer body" }
  representative { Representative.make! }
  question { Question.make!(status: 'approved') }
end

PartyComment.blueprint do
  body  { 'This is my body' }
  party
  issue
  parliament_period
end

Position.blueprint do
  parties { [Party.make!] }
  issue { Issue.make! }
  description { 'the reason i am here in paris is...'}
  title { 'parties chose to...' }
end
