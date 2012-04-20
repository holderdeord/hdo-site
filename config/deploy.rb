require 'bundler/capistrano'

set :application, "hdo-site"

set :scm, :git
set :repository, "git://github.com/holderdeord/hdo-site"
set :branch, 'master'

set :use_sudo, false
set :deploy_via, :remote_cache
set :import_root, '/code/hdo-storting-importer'

if ENV['VAGRANT']
  set :user, 'hdo'
  set :domain, 'localhost'
  set :port, 2222
else
  set :user, 'hdo'
  set :domain, 'beta.holderdeord.no'
end

set :deploy_to, "/webapps/#{application}"

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

namespace :db do
  task :config, :except => { :no_release => true }, :role => :app do
    run "cp -f /home/hdo/.hdo-database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:finalize_update", "db:config"

namespace :import do
  task(:all) { run "cd #{import_root} && RAILS_ENV=production APP_ROOT=#{current_path} bin/import.rb all" }
  task(:dld) { run "cd #{import_root} && RAILS_ENV=production APP_ROOT=#{current_path} bin/import.rb dld" }
  task(:promises) { run "cd #{import_root} && RAILS_ENV=production APP_ROOT=#{current_path} bin/import.rb promises" }
end

namespace :cache do
  task(:clear) { run "rm -r #{current_path}/public/cache/*"}
end

namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      # invoke with
      # UNTIL="16:00 MST" REASON="a database upgrade" cap deploy:web:disable

      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end
