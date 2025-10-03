require "sidekiq/web"

Rails.application.routes.draw do
  # Authentication routes
  resource :session
  resources :passwords, param: :token

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
