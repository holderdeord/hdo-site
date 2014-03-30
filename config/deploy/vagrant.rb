set :git_shallow_clone, 1
set :rails_env, :staging

role :web, '192.168.1.11'
role :app, '192.168.1.11'
role :db,  '192.168.1.11', :primary => true
