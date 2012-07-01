# encoding: utf-8
require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
	name {"user #{sn}" }
	email {"user#{sn}@email.com}"}
	password {"abcd1234"}
	password_confirmation {"abcd1234"}
end

Vote.blueprint do
	issues { [Issue.make] }
	time { Time.now }
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
end