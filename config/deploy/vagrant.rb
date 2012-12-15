set :port,    2222
set :git_shallow_clone, 1

role :web, 'localhost'
role :app, 'localhost'
role :db,  'localhost', :primary => true
