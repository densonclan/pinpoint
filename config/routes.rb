Ghpinpoint::Application.routes.draw do


  get "newdash" => "newdash#index", :as => :newdash
  root :to => 'newdash#index'

  resources :documents do
    collection do
      get 'search'
    end
  end

  resources :folders do
    resources :uploaded_files, only: [:create, :destroy, :show]
    resources :shared_folders, only: [:index, :create, :destroy]
    member do
      get :browse
    end
  end

  resources :periods, :except => :show do
    member do
      get :review
      post :compile
    end
  end

  resources :addresses do
    collection do
      get :search
      get 'advanced'
      get :lookup
    end
  end

  #
  # => Resources without the SHOW action
  #
  resources :clients, :business_managers, :distributors, :pages, :except => :show do
    collection do
      get 'search'
    end
  end

  resources :options, :transports, :comments, :export_templates, :record_locks, :order_exceptions, :distributions
  resources :postcode_sectors do
    collection do
      post :import
      get :search
    end
  end
  resources :pods do
    collection do
      post :import
      get :search
    end
  end

  get 'orders/:type', to: 'orders#index', as: 'list_orders', constraints: { type: /all|previous|next|duplicated/ }

  resources :orders do
    collection do
      get 'search'
      get 'advanced'
      get 'update_status'
      post 'update_orders'
    end
    member do
      get :notes
      get :copy
    end
  end

  get 'stores/:type', to: 'stores#index', as: 'list_stores', constraints: { type: /nologo|noorders|participating/ }


  resources :stores do
    collection do
      get 'lookup'
      get 'search'
      get 'advanced'
      get :suggest
      delete '/:id/address/:address_id', :action => 'destroy_address', :as => 'destroy_address'
      get :export
    end

    member do
      get :other
      get :map
      get :documents
      get :notes
      get :orders
    end
  end

  resources :messages, :except => [:edit, :update] do
    collection do
      get 'sent'
      get 'save-task/:message_id', :action => 'save_task', :as => 'save_task'
      get 'archived'
      put 'archive/:id', :action => 'archive', :as => 'archive'
      put 'unarchive/:id', :action => 'unarchive', :as => 'unarchive'
    end
  end

  resources :tasks do

    member do
      post :archive
      post :unarchive
    end
    collection do
      get 'assigned'
      get 'calendar'
      get 'archived'
      get 'store'
      put 'archive/:id', :action => 'archive', :as => 'archive'
      put 'unarchive/:id', :action => 'unarchive', :as => 'unarchive'
    end
  end

  #
  # => Department, without the SHOW action
  #
  resources :departments, :except => :show

  #
  # => Reports module, with custom action
  #
  resources :reports,:except => [:show, :edit, :destroy, :update] do
    collection do
      get 'date'
      get 'period'
      get 'quantities'
      get 'activity/:type', :action => 'activity', :as => 'activity'
      # Clients
      get 'clients'
      # Business Managers
      get 'business_managers'
      get 'business_manager'
      # Stores
      get 'stores'
      get :store
    end
  end

  #
  # Importer, except the REST methods, REFACTOR
  #
  resources :importer, :except => [:show, :edit, :destroy, :update] do
    member do
      get :template
      post :cancel
    end
    collection do
      get 'file'
      get 'history'
    end
  end

  resources :exporter do
    collection do
      post 'processor'
    end
  end

  resources :invoice do
    collection do
      post 'processor'
    end
  end

  resources :bargain_booze

  resources :users do
    member do
      get :activate
      get :deactivate
    end
  end

  #
  # => Desvise route
  #
  devise_for :users, :path => "auth", :path_names => {
    :sign_in => 'login',
    :sign_out => 'logout',
    :password => 'secret',
    :confirmation => 'verification',
    :unlock => 'unblock',
    :registration => 'register',
    :sign_up => 'cmon_let_me_in'
  }

  get "dashboard" => "dashboard#index", :as => :dashboard
  root :to => 'dashboard#index'
end