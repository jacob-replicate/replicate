require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users
  post "/stripe-webhooks", to: "stripe_webhooks#create"

  get "/terms", to: "static#terms"
  get "/privacy", to: "static#privacy"
  get "/features", to: "static#features"
  get "/pricing", to: "static#pricing"

  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]

  root "static#index"
end