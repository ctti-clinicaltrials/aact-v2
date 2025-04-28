Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :documentation, only: [ :index, :update ]
      resources :snapshots, only: [ :index ] do
        collection do
          get :latest
        end
      end
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
