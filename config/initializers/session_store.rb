Rails.application.configure do
  config.session_store :cache_store, key: ENV['APP_SESSION_KEY']
end
