Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV['GOOGLE_CLIENT_ID'],
    ENV['GOOGLE_CLIENT_SECRET'],
    {
      scope: 'email,profile',
      prompt: 'select_account'
    }
end

# Security: Only allow POST to initiate OAuth (CSRF protection via omniauth-rails_csrf_protection gem)
OmniAuth.config.allowed_request_methods = [:post]

# Security: Fail loudly on auth errors instead of silently redirecting
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}