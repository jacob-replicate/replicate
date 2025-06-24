require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users
  post "/stripe-webhooks", to: "stripe_webhooks#create"

  get "/terms", to: "static#terms"
  get "/privacy", to: "static#terms"

  root "static#index"
end