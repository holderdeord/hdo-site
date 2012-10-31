Hdo::Application.routes.draw do

  #
  # Users
  #

  devise_for :users
  resources :users

  #
  # issues
  #

  resources :issues

  get 'issues/:id/votes'        => 'issues#votes', as: :issue_votes
  get 'issues/:id/edit/:step'   => 'issues#edit', as: :edit_issue_step
  get 'issues/:id/votes/search' => "issues#votes_search", as: :issue_votes_search

  #
  # districst
  #

  resources :districts,  :only => [:index, :show]

  #
  # categories
  #

  resources :categories, :only => [:index, :show] do
    member do
      get 'promises'
      get 'promises/parties/:party' => 'categories#promises'
    end
  end
  get 'categories/:id/subcategories' => "categories#subcategories"

  #
  # parties, committees, topics
  #
  #
  resources :parties,         :only => [:index, :show]
  resources :committees,      :only => [:index, :show]
  resources :topics

  #
  # promises
  # 
  resources :promises,        :only => [:index]
  get 'promises/page/:page'   => 'promises#index'
  get 'promises/show/:id'     => 'promises#show'
  get 'promises/category/:id' => 'promises#category'

  #
  # parliament_issues
  #

  resources :parliament_issues, :path => 'parliament-issues', :only => [:index, :show]
  get 'parliament-issues/page/:page' => 'parliament_issues#index'

  #
  # representatives
  #

  resources :representatives, :only => [:index, :show]
  get 'representatives/index/name'     => 'representatives#index_by_name', as: :representatives_by_name
  get 'representatives/index/party'    => 'representatives#index_by_party', as: :representatives_by_party
  get 'representatives/index/district' => 'representatives#index_by_district', as: :representatives_by_district
  get 'representatives/:id/page/:page' => 'representatives#show'

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
  # docs
  #

  get "docs/index"
  get "docs/analysis"

  # global search
  get 'search/all' => 'search#all', as: :search_all

  root :to => 'home#index'
end
