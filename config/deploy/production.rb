#
# app servers
#

role :app, 'app1.holderdeord.no', 'app2.holderdeord.no'

#
# all the app servers are also 'web' servers (running nginx, need maintenance page etc)
#

role :web, 'app1.holderdeord.no', 'app2.holderdeord.no'

#
# app1 doesn't really have the db, but is used to run
# migrations and thus have the :db role in capistrano.
#

role :db, 'app1.holderdeord.no', :primary => true
