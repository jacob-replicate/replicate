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

  post "/webhooks/postmark", to: "postmark_webhooks#create"
  post "/webhooks/missive", to: "missive_webhooks#create"

  get "/terms", to: "static#terms"
  get "/privacy", to: "static#privacy"
  get "/billing", to: "static#billing"
  get "/security", to: "static#security"
  get '/sev', to: "static#coaching"
  get '/contacts/:id/unsubscribe', to: "contacts#unsubscribe"
  post '/contacts/:id/unsubscribe', to: "contacts#unsubscribe_confirm"
  get '/contacts/:id/resubscribe', to: "contacts#resubscribe"
  post '/contacts/:id/resubscribe', to: "contacts#resubscribe_confirm"
  get '/members/:id/unsubscribe', to: "members#unsubscribe"
  post '/members/:id/unsubscribe', to: "members#unsubscribe_confirm"
  get '/members/:id/resubscribe', to: "members#resubscribe"
  post '/members/:id/resubscribe', to: "members#resubscribe_confirm"

  resources :conversations, only: [:show]
  resources :messages, only: [:create]
  resources :organizations, only: [:create]

  root "static#index"
end