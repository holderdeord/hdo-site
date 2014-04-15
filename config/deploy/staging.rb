role :web, 'staging.holderdeord.no'
role :app, 'staging.holderdeord.no'
role :db,  'staging.holderdeord.no', :primary => true

set :rails_env, 'staging'