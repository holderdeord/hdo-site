Hdo::Application.routes.draw do

  #
  # user sign-in
  #

  devise_for :users

  #
  # admin
  #

  namespace :admin do
    resources :issues do
      member do
        get 'edit/:step'   => 'issues#edit',         as: :edit_step
        get 'votes/search' => "issues#votes_search", as: :vote_search
      end
    end

    resources :users
    resources :topics
    resources :representatives, only: [:index, :edit, :update]

    # S&S
    resources :questions, only: [:index, :edit, :update, :destroy] do
      resources :answers, except: :show

      member do
        put 'approve' => 'questions#approve'
        put 'reject'  => 'questions#reject'
      end
    end

    root to: "dashboard#index"
  end


  #
  # non-admin issues, topics
  #

  resources :issues, only: [:index, :show, :votes] do
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
  get "home/contact"
  get "home/join"
  get "home/support"
  get "home/member"
  get "home/people"
  get "home/future"
  get "home/method" => "home#about_method", as: :home_method

  #
  # Q & A
  #

  resources :questions

  #
  # norwegian aliases - don't overdo this without a proper solution
  #

  get "bli-med" => "home#join"

  #
  # docs
  #

  get "docs/index"
  get "docs/analysis"

  #
  # global search
  #

  get 'search/all' => 'search#all', as: :search_all
  get 'search/autocomplete' => 'search#autocomplete', :as => :search_autocomplete

  #
  # robots
  #

  get '/robots.txt' => 'home#robots'

  #
  # health check for varnish/others
  #

  get '/healthz' => 'home#healthz'

  root to: 'home#index'
end
