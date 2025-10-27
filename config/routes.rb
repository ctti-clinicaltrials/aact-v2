require "sidekiq/web"

Rails.application.routes.draw do
  # Authentication routes
  resource :sign_up
  resource :session
  resources :passwords, param: :token

  # Database access setup routes (Step 2 - initial setup only)
  resource :database_access, only: [ :new, :create ], controller: :database_access

  # Settings routes
  namespace :settings do
    resource :profile, only: [ :show, :update ]
    resource :password, only: [ :show, :update ]
    resource :database_access, only: [ :show ] do
      get :reveal_password, on: :collection
      post :verify_password, on: :collection
    end

    root to: redirect("/settings/profile")
  end

  # Admin routes
  namespace :admin do
    resources :users, only: [ :index ]
  end

  # Root route
  root "home#index"

  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :documentation, only: [ :index, :update ]
      resources :snapshots, only: [ :index ] do
        collection do
          get :latest
        end
      end
      get "analytics/database_usage"
      get "analytics/user_usage"

      # Logs processing endpoint
      post "logs/process_json"
    end

    namespace :v2 do
      get "mapping", to: "data_mapping#index"
    end
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
