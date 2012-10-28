Hdo::Application.routes.draw do

  #
  # user sign-in
  #

  devise_for :users

  #
  # admin
  #

  namespace :admin do
    resources :issues, except: :show do
      member do
        get 'edit/:step'   => 'issues#edit',         as: :edit_step
        get 'votes/search' => "issues#votes_search", as: :vote_search
      end
    end

    resources :users
    resources :topics

    root to: "dashboard#index"
  end


  #
  # non-admin issues, topics
  #

  resources :issues, only: [:show, :votes] do
    member do
      get 'votes' => 'issues#votes'
    end
  end

  resources :topics, only: :show

  #
  # districst
  #

  resources :districts, only: [:index, :show]

  #
  # categories
  #

  resources :categories, only: [:index, :show] do
    member do
      get 'promises'
      get 'promises/parties/:party' => 'categories#promises'
      get 'subcategories'           => 'categories#subcategories'
    end
  end

  #
  # parties, committees
  #

  resources :parties,    only: [:index, :show]
  resources :committees, only: [:index, :show]

  #
  # promises
  #

  resources :promises, only: [:index]
  get 'promises/page/:page' => 'promises#index'

  #
  # parliament_issues
  #

  resources :parliament_issues, path: 'parliament-issues', only: [:index, :show]
  get 'parliament-issues/page/:page' => 'parliament_issues#index'

  #
  # representatives
  #

  resources :representatives, only: [:index, :show] do
    member do
      get 'page/:page' => 'representatives#show'
    end
  end

  get 'representatives/index/name'     => 'representatives#index_by_name', as: :representatives_by_name
  get 'representatives/index/party'    => 'representatives#index_by_party', as: :representatives_by_party
  get 'representatives/index/district' => 'representatives#index_by_district', as: :representatives_by_district

  #
  # votes
  #

  resources :votes, only: [:index, :show] do
    member do
      get 'propositions'
    end
  end

  get 'votes/page/:page' => 'votes#index'

  #
  # home
  #

  get "home/index"
  get "home/about"
  get "home/press"
  get "home/login_status"
  get "home/join"
  get "home/support"
  get "home/member"
  get "home/people"
  get "home/method" => "home#about_method", as: :home_method

  #
  # norwegian aliases - don't overdo this without a proper solution
  #

  get "bli-med" => "home#join"

  #
  # docs
  #

  get "docs/index"
  get "docs/analysis"

  # global search
  get 'search/all' => 'search#all', as: :search_all
  get 'search/autocomplete' => 'search#autocomplete', :as => :search_autocomplete

  root to: 'home#index'

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
>>>>>>> First stab at new autocomplete action in search_controller
end
