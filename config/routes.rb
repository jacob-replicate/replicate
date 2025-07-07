require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users
  post "/stripe-webhooks", to: "stripe_webhooks#create"

  get "/demo", to: "static#demo"
  get "/terms", to: "static#terms"
  get "/privacy", to: "static#privacy"
  get "/pricing", to: "static#pricing"
  get "/security", to: "static#security"
  get '/knowledge-gaps', to: "static#knowledge_gaps"

  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]

  root "static#index"
end