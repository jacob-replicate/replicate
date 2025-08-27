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

  devise_for :users
  post "/webhooks/stripe", to: "stripe_webhooks#create"
  post "/webhooks/postmark", to: "postmark_webhooks#create"

  get "/demo", to: "static#demo"
  get "/terms", to: "static#terms"
  get "/privacy", to: "static#privacy"
  get "/billing", to: "static#billing"
  get "/security", to: "static#security"
  get '/sev', to: "static#coaching"
  get '/contacts/:id/unsubscribe', to: "contacts#unsubscribe"

  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]
  resources :organizations, only: [:create]
  resources :subscribers, only: [:create, :edit, :destroy]

  root "static#index"
end