source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use SQLite as the database for Active Record
gem "sqlite3"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Vite.js integration for Rails [https://vite-ruby.netlify.app/]
gem "vite_rails"
# Inertia.js Rails adapter [https://github.com/inertiajs/inertia-rails]
gem "inertia_rails"

# Send emails via Postmark [https://github.com/ActiveCampaign/postmark-rails]
gem "postmark-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Artisans UI Component Library
gem "artisans_ui", git: "https://github.com/artisanscompany/artisans_ui.git", branch: "main"

# Blog Engine - TEMPORARILY DISABLED
# Disabled due to missing dependency: blog_engine expects ::Admin::BaseController
# to exist in the host application, which is not yet implemented.
# To re-enable: create app/controllers/admin/base_controller.rb in host app
# gem "blog_engine", git: "https://github.com/artisanscompany/blog_engine.git", branch: "main"

group :development, :test do
  # Load environment variables from .env
  gem "dotenv-rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Preview emails in browser with web UI at /letter_opener
  gem "letter_opener_web"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
