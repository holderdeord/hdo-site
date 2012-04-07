require 'bundler/capistrano'
load 'deploy/assets'

set :application, "hdo-site"

set :scm, :git
set :repository,  "git://github.com/holderdeord/hdo-site"
set :branch, 'master'

set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, "/sites/hdo.jaribakken.com/"

set :user, 'jari'
set :domain, 'hdo.jaribakken.com'

role :web, domain
role :app, domain
role :db, domain, :primary => true

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end