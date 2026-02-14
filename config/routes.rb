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

  get "/terms", to: "static#terms"
  get "/privacy", to: "static#privacy"
  get "/billing", to: "static#billing"
  get "/security", to: "static#security"
  get '/incidents(/:sharing_code)', to: "conversations#show"
  get '/members/:id/unsubscribe', to: "members#unsubscribe"
  post '/members/:id/unsubscribe', to: "members#unsubscribe_confirm"
  get '/members/:id/resubscribe', to: "members#resubscribe"
  post '/members/:id/resubscribe', to: "members#resubscribe_confirm"
  post '/sessions/pulse', to: "sessions#pulse"
  get '/growth', to: "static#growth"

  # Demo conversation route - renders React app
  get '/conversations/:uuid', to: "static#index", constraints: { uuid: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i }

  resources :conversations, only: [:show, :update]
  get '/conversations/:id/destroy', to: "conversations#destroy"
  resources :messages, only: [:create]
  resources :organizations, only: [:create]

  # OAuth routes - must be before wildcard routes
  post '/auth/:provider', to: lambda { |_| [404, {}, ['Not Found']] } # OmniAuth intercepts this
  get '/auth/:provider/callback', to: "sessions#oauth_create"
  get '/auth/failure', to: "sessions#oauth_failure"
  delete '/logout', to: "sessions#destroy"

  # Topic routes (simplified: Category -> Topic -> Conversation)
  post '/:code/populate', to: "topics#populate", as: "populate_topic"

  # Conversation routes under topic (these replace Experience routes)
  post '/:topic_code/:conversation_code/populate', to: "conversations#populate", as: "populate_conversation"
  delete '/:topic_code/:conversation_code', to: "conversations#destroy_template", as: "destroy_conversation_template"
  get '/:topic_code/:conversation_code', to: "conversations#show_by_code", as: "topic_conversation"

  # Topic show (must be last of the wildcard routes)
  get '/:code', to: "topics#show", as: "topic"

  root "static#index"
end