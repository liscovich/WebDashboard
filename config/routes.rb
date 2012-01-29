WebDashboard::Application.routes.draw do
  devise_for :user, :controllers => {:registrations => 'registrations'}

  resources :logs, :only => [:index] do
    collection do
      get :delete_all
    end
  end

  resource  :home, :as => 'home', :only => :show
  resource  :directory, :as => 'directory', :only => :show
  resources :experiments, :only => :index
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

  resources :events, :only => :index

  resources :games do
    collection do
      get :delete_all
      get :frame #TODO move to members?
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
  
  resource :user do
    member do
      post :complete
      post :info
      post :researcher
      post :password
    end
  end

  resources :authentications
  match '/auth/:provider/callback' => 'authentications#create'
  
  root :to => 'trials#index'
end
