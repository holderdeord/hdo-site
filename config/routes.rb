Hdo::Application.routes.draw do

  #
  # api
  #

  namespace :api do
    root to: 'root#index'

    resources :parties, only: [:index, :show]
    resources :representatives, only: [:index, :show]
    resources :issues, only: [:index, :show]

  end

  #
  # user sign-in
  #

  devise_for :users, controllers: { sessions: 'sessions', passwords: 'passwords' }

  #
  # admin
  #

  namespace :admin do
    resources :issues do
      member do
        # new
        get 'edit/next'  => 'new_issues#edit', as: :edit_next
        put  'edit/next' => 'new_issues#update'

        # old
        get 'edit/:step'   => 'issues#edit',         as: :edit_step
        get 'votes/search' => "issues#votes_search", as: :vote_search
      end

      collection do
        post 'next'              => 'new_issues#create',  as: :create_next
        get  'new/next'          => 'new_issues#new',     as: :new_next
        get  'promises/:ids'     => 'new_issues#promises'
        get  'propositions/:ids' => 'new_issues#propositions'
      end
    end

    resources :users
    resources :governments, except: :show
    resources :propositions, only: [:index, :edit, :update]
    resources :representatives, only: [:index, :edit, :update] do
      get 'activate'       => 'representatives#activate',       as: :activate
      get 'reset_password' => 'representatives#reset_password', as: :reset_password
    end

    # S&S
    resources :questions, only: [:index, :edit, :update] do
      member do
        put 'approve'        => 'questions#approve'
        put 'reject'         => 'questions#reject'

        get  'email/question/approved/rep'  => 'questions#question_approved_email_rep',  as: :question_approved_email_rep
        get  'email/question/approved/user' => 'questions#question_approved_email_user', as: :question_approved_email_user
        post 'email/question/rejected/user' => 'questions#question_rejected_email_user', as: :question_rejected_email_user
        get  'email/answer/approved/user'   => 'questions#answer_approved_email_user',   as: :answer_approved_email_user

        get  'answer' => 'questions#create_answer', as: :create_answer
      end
    end

    root to: "dashboard#index"
  end

  #
  # representative sign-in
  #

  devise_for :representative, controllers: { confirmations: 'confirmations', sessions: 'sessions', passwords: 'passwords' }
  devise_scope :representative do
    put  'representative/confirmation' => 'confirmations#update',         as: :update_representative_confirmation
    get  'representative/edit'         => 'devise/registrations#edit',    as: :edit_representative_registration
    put  'representative'              => 'devise/registrations#update',  as: :representative_registration
  end

  get  'representative'                       => 'representative#index',         as: :representative_root
  # get  'representative/questions/:id'         => 'representative#show_question', as: :representative_question
  # post 'representative/questions/:id/answers' => 'representative#create_answer', as: :representative_question_answers


  #
  # non-admin issues
  #

  resources :issues, only: [:index, :show, :votes] do
    member do
      get 'votes'      => 'issues#votes'
      get 'widget'     => 'widgets#issue'
      get 'admin_info' => 'issues#admin_info', as: :admin_info
      get 'next'       => 'issues#next'
    end
  end

  #
  # districts
  #

  resources :districts, only: [:index, :show]

  #
  # categories
  #

  resources :categories, only: [:index, :show]

  #
  # parties, committees
  #

  resources :parties,    only: [:index, :show] do
    member do
      get 'widget' => 'widgets#party'
    end
  end
  resources :committees, only: [:index, :show]

  #
  # promises
  #

  resources :promises, only: [:index, :show] do
    collection do
      get ':promises/widget' => 'widgets#promises', as: :widget
    end
  end


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
      get 'widget'     => 'widgets#representative'
    end
  end

  get 'representatives/index/name'     => 'representatives#index_by_name', as: :representatives_by_name
  get 'representatives/index/party'    => 'representatives#index_by_party', as: :representatives_by_party
  get 'representatives/index/district' => 'representatives#index_by_district', as: :representatives_by_district

  #
  # propositions
  #

  resources :propositions, only: [:index, :show]

  #
  # votes
  #

  resources :votes, only: [:index, :show] do
    collection do
      get 'page/:page' => 'votes#index'
    end

    member do
      get 'propositions'
    end
  end


  #
  # widgets
  #

  get 'widgets'           => 'widgets#load', format: :js, as: :widget_load
  get 'widgets/topic'     => 'widgets#topic'
  get 'widgets/config'    => 'widgets#configure'

  #
  # home
  #

  get 'home/index'
  get 'home/contact'
  get 'home/people'
  get 'home/faq'        => 'home#faq', as: :home_faq
  get 'home/friends'

  get 'home/method'     => 'home#about'
  get 'home/about'      => 'home#about',    as: :home_about
  get 'home/terms'      => 'home#terms',    as: :home_terms
  get 'home/statutes'   => 'home#statutes', as: :home_statutes

  # deprecated
  get 'home/support', to: redirect('/')
  get 'home/member',  to: redirect('/')


  #
  # Q & A
  #

  resources :questions, only: [:index, :create, :show, :new] do
    collection do
      get 'conduct'
      get 'disabled' => 'questions#disabled', as: :disabled
    end
  end
  get 'questions/all/:category' => 'questions#all'

  #
  # norwegian aliases - don't overdo this without a proper solution
  #

  #
  # docs
  #

  get "docs/index"
  get "docs/analysis"

  #
  # global search
  #

  get 'search/all' => 'search#all', as: :search_all
  get 'search/autocomplete' => 'search#autocomplete', as: :search_autocomplete
  # get 'search/promises' => 'search#promises', as: :search_promises

  #
  # various
  #

  get 'robots.txt'    => 'home#robots'
  get 'info/revision' => 'home#revision'
  get 'healthz'       => 'home#healthz' # cheap health check for varnish/others

  root to: 'home#index'
end
