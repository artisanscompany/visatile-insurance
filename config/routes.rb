Rails.application.routes.draw do
  # Email preview in development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :posts do
    post :test_worker, on: :collection
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Contact form route (POST only, form is on homepage)
  post "contact", to: "contacts#create", as: :contact

  # Defines the root path route ("/")
  root "pages#index"
end
