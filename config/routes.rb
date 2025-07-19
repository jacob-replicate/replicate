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
  get "/billing", to: "static#billing"
  get "/security", to: "static#security"
  get '/knowledge-gaps', to: "static#knowledge_gaps"
  get '/coaching', to: "static#coaching"

  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]
  resources :organizations, only: [:create]

  root "static#index"
end