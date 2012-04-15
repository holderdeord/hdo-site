require 'bundler/capistrano'

set :application, "hdo-site"

set :scm, :git
set :repository,  "git://github.com/holderdeord/hdo-site"
set :branch, 'master'

set :use_sudo, false
set :deploy_via, :remote_cache

if ENV['VAGRANT']
  set :user, 'vagrant'
  set :domain, 'localhost'
  set :port, 2222
  set :password, 'vagrant'
  set :deploy_to, "/webapps/#{application}"
else
  set :user, 'jari'
  set :domain, 'hdo.jaribakken.com'
  set :deploy_to, "/sites/hdo.jaribakken.com/"
end

role :web, domain
role :app, domain
role :db, domain, :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end