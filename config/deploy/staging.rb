role :web, 'hetzner03.holderdeord.no'
role :app, 'hetzner03.holderdeord.no'
role :db,  'hetzner03.holderdeord.no', :primary => true

set :rails_env, 'staging'