WebDashboard::Application.routes.draw do
  devise_for :users, :controllers => {:omniauth_callbacks => 'authentications', :registrations => 'registrations'}
  
  namespace :admin do
  end

  namespace :players do
    get 'auth/:provider' => 'authentications#thought_provider'
  end

  namespace :researchers do
    get 'auth/:provider' => 'authentications#thought_provider'
  end

  resources :logs, :only => [:index] do
    collection do
      get :delete_all
    end
  end

  resource  :home, :as => 'home', :only => :show
  resource  :directory, :as => 'directory', :only => :show
  resources :experiments do
    resources :games
  end
  resources :trials, :only => :index
  
  resources :hits, :except => :show do
    collection do
      get :dispose_all
    end
    member do
      get :approve
      get :reject
      get :bonus
      get :dispose
    end
  end

  resources :events, :only => [:index, :create]

  resources :games do
    collection do
      get :delete_all
      get :frame #TODO move to members?
      get :thanks
    end
    member do
      get :mturk
      get :template
      get :log
      get :dashboard
      get :summary
      get :state
    end

    resources :users,  :only => [], :controller => "games/users" do
      member do
        get :earnings
        get :record_submission
        get :pay
      end
    end
  end
  
  resources :users do
    member do
#      post :info
      post :researcher
      put  :update_password
    end
  end

  resources :authentications
  match '/auth/:provider/callback' => 'authentications#create'
  
  root :to => 'trials#index'
end
