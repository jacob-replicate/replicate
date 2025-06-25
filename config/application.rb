require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Advance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "America/New_York"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.smtp_settings = {
      user_name: 'apikey', # This is the string literal 'apikey', NOT the ID of your API key
      password: ENV["SENDGRID_API_KEY"],
      domain: 'replicate.info',
      address: 'smtp.sendgrid.net',
      port: 587,
      authentication: :plain,
      enable_starttls_auto: true
    }

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end