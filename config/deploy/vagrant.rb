set :git_shallow_clone, 1
set :rails_env, :staging

role :web, '192.168.1.12'
role :app, '192.168.1.12'
role :db,  '192.168.1.12', :primary => true
