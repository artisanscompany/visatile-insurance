Rails.application.routes.draw do
  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  # Authentication routes
  resource :session, only: %i[new create destroy] do
    resource :magic_link, only: %i[show create], module: :sessions
  end

  resource :registration, only: %i[new create] do
    resource :completion, only: %i[show create], module: :registrations
  end

  get "accounts/select", to: "account_selector#show", as: :account_selector

  # Invite acceptance (non-tenanted)
  get "invites/:token", to: "invite_acceptances#show", as: :invite
  post "invites/:token/accept", to: "invite_acceptances#create", as: :accept_invite

  # Panel API endpoints (JSON, no session state)
  namespace :api do
    namespace :insurance do
      resource :quote, only: %i[create]
      resource :checkout, only: %i[create]
      get "pdf_download/:policy_id", to: "pdf_downloads#show", as: :insurance_pdf_download
    end
    resource :session, only: %i[create] do
      resource :magic_link, only: %i[create], module: :sessions
    end
  end

  # Public insurance funnel (no auth required)
  namespace :insurance do
    resource :quote, only: %i[new create]
    resource :quote_review, only: %i[show]
    resource :traveler_detail, only: %i[new create]
    resource :checkout, only: %i[new create]
    resource :confirmation, only: %i[show]
  end

  # Stripe webhook
  namespace :stripe do
    resource :webhook, only: %i[create]
  end

  # Account-scoped routes
  scope "/:account_id" do
    get "dashboard", to: "dashboard#show", as: :dashboard
    resource :profile, only: %i[edit update]
    resources :members, only: %i[index update destroy]
    resources :invites, only: %i[create destroy] do
      resource :resend, only: %i[create], module: :invites
    end

    # Insurance policy views (authenticated, account-scoped)
    resources :insurance_policies, only: %i[index show] do
      scope module: :insurance_policies do
        resource :pdf_download, only: %i[show]
        resource :retry, only: %i[create]
        resource :refund, only: %i[new create]
      end
    end

    # Admin views (superuser only)
    namespace :admin do
      resources :failed_policies, only: %i[index]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public landing page
  resource :landing, only: [ :show ], controller: :landing

  # Defines the root path route ("/")
  root "landing#show"
end
