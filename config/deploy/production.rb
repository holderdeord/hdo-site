#
# app servers
#

role :app, 'files.holderdeord.no'
role :web, 'files.holderdeord.no'
role :db, 'files.holderdeord.no', :primary => true
