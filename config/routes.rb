require "sidekiq/web"

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    secure_user = ENV.fetch("SIDEKIQ_USERNAME", "admin")
    secure_pass = ENV.fetch("SIDEKIQ_PASSWORD", "puppies123")

    ActiveSupport::SecurityUtils.secure_compare(username, secure_user) &
      ActiveSupport::SecurityUtils.secure_compare(password, secure_pass)
  end

  Rails.application.routes.draw do
    mount Sidekiq::Web => "/sidekiq"
  end

  # API routes
  namespace :api do
    resources :conversations, only: [:index, :show, :update] do
      resources :messages, only: [:create]
    end
  end

  # Server-rendered pages (non-SPA)
  get "/billing", to: "static#billing"

  # OAuth
  post '/auth/:provider', to: lambda { |_| [404, {}, ['Not Found']] }
  get '/auth/:provider/callback', to: "sessions#oauth_create"
  get '/auth/failure', to: "sessions#oauth_failure"
  delete '/logout', to: "sessions#destroy"

  # SPA catch-all - React Router handles everything else
  get '*path', to: "static#index", constraints: ->(req) { !req.path.start_with?('/api', '/sidekiq', '/assets') }
  root "static#index"
end