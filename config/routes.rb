Hdo::Application.routes.draw do
  devise_for :users

  resources :users
  resources :topics
  get 'topics/:id/votes'        => 'topics#votes', :as => :topic_votes
  get 'topics/:id/edit/:step'   => 'topics#edit', :as => :edit_topic_step
  get 'topics/:id/votes/search' => "topics#votes_search", :as => :topic_votes_search

  resources :districts,       :only => [:index, :show]
  resources :categories,      :only => [:index, :show]
  resources :categories do
    get 'promises', :on => :member
  end

  resources :parties,         :only => [:index, :show]
  resources :committees,      :only => [:index, :show]
  resources :fields

  resources :promises,        :only => [:index]        # TODO: :create, :show and :edit behind auth
  get 'promises/page/:page' => 'promises#index'
  get 'promises/show/:id' => 'promises#show'
  get 'promises/category/:id' => 'promises#category'

  resources :issues, :only => [:index, :show]
  get 'issues/page/:page' => 'issues#index'

  resources :representatives, :only => [:index, :show]
  get 'representatives/index/name'     => 'representatives#index_by_name', :as => :representatives_by_name
  get 'representatives/index/party'    => 'representatives#index_by_party', :as => :representatives_by_party
  get 'representatives/index/district' => 'representatives#index_by_district', :as => :representatives_by_district
  get 'representatives/:id/page/:page' => 'representatives#show'

  resources :votes, :only => [:index, :show]
  get 'votes/page/:page' => 'votes#index'
  get 'votes/index/all'  => 'votes#all', :as => :all_votes

  get "home/index"
  get "home/about"
  get "home/press"
  get "home/login_status"
  get "home/join"
  get "home/support"
  get "home/people"
  get "home/method" => "home#about_method", :as => :home_method

  get "docs/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
