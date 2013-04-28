require 'bundler/capistrano'
require 'capistrano/maintenance'

set :stages, %w(vagrant staging production)

if ENV['VAGRANT']
  set :default_stage, :vagrant
end

require 'capistrano/ext/multistage'

set :user,            'hdo'
set :application,     'hdo-site'
set :scm,             :git
set :repository,      'git://github.com/holderdeord/hdo-site'
set :branch,          ENV['BRANCH'] || 'master'
set :deploy_to,       "/webapps/#{application}"
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :shared_children, shared_children + %w[public/uploads tmp/downloads]
set :passenger_restart_strategy, :hard

namespace :deploy do
  task(:start) {}
  task(:stop) {}

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  namespace :web do
    task :disable, :roles => :web do
      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end

namespace :config do
  task :symlink do
    cmd = {
       "#{shared_path}/config/database.yml" => "#{release_path}/config/database.yml",
       "#{shared_path}/config/env.yml"      => "#{release_path}/config/env.yml"
    }.map { |src, des| "ln -nfs #{src} #{des}"}.join(" && ")

    run cmd
  end
end

namespace :search do
  task :reindex, :roles => :db, :only => { :primary => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} search:reindex"
  end
end

namespace :cache do
  task :precompute do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} cache:precompute"
  end

  namespace :pages do
    task(:clear) { run "rm -r #{current_path}/public/cache/*" }
  end

  task :images do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} images:reset"
  end
end

# alternatively after:update_code, but need to get things in the right order here.
before 'deploy:assets:precompile', 'config:symlink'

if exists?(:stage)
  if stage.to_s != 'vagrant'
    token = ENV['HIPCHAT_API_TOKEN'] or abort "must set HIPCHAT_API_TOKEN"
    require "hipchat/capistrano"

    set :hipchat_token,     token
    set :hipchat_room_name, "Teknisk"
    set :hipchat_announce,  false
  end
end