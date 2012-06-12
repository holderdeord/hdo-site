require 'bundler/capistrano'

set :application, "hdo-site"

set :scm, :git
set :repository, "git://github.com/holderdeord/hdo-site"
set :branch, 'master'

set :use_sudo, false
set :passenger_restart_strategy, :hard
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
  cmd = "cd %s && RAILS_ENV=production bin/hdo-converter --app-root %s --source api %s"

  task(:all)       { run(cmd % [import_root, current_path, 'all'])      }
  task(:dld)       { run(cmd % [import_root, current_path, 'dld'])      }
  task(:promises)  { run(cmd % [import_root, current_path, 'promises']) }
  task(:votes)     { run(cmd % [import_root, current_path, 'votes'])    }
end

namespace :clear do
  cmd = "cd %s && RAILS_ENV=production bundle exec rake db:clear:%s"

  desc 'Clear promises'
  task(:promises) { run(cmd % [current_path, 'promises']) }

  desc 'Clear votes'
  task(:votes)    { run(cmd % [current_path, 'votes'])    }
end

namespace :cache do
  desc 'Clear the page cache.'
  task(:clear) { run "rm -r #{current_path}/public/cache/*"}
end

namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end
