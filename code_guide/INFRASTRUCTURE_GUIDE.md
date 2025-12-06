# Infrastructure & Configuration Guide

> **Rails Extensions, Email, Files, Config & Deployment** - Infrastructure patterns from the 37signals Fizzy codebase

This guide covers Rails infrastructure and configuration. For backend patterns, see [BACKEND_GUIDE.md](./BACKEND_GUIDE.md). For frontend, see [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md).

---

## Table of Contents

1. [Rails Extensions & Monkey Patching](#rails-extensions--monkey-patching)
2. [Email Patterns](#email-patterns)
3. [File Upload & Storage](#file-upload--storage)
4. [Current Attributes & Context](#current-attributes--context)
5. [Routing Conventions](#routing-conventions)
6. [Configuration & Environment](#configuration--environment)
7. [Deployment & DevOps](#deployment--devops)
8. [Infrastructure Checklist](#infrastructure-checklist)

---

## Rails Extensions & Monkey Patching

### Organization in lib/rails_ext

Keep all Rails extensions organized and auto-loadable:

```ruby
# config/initializers/extensions.rb
Dir[Rails.root.join("lib/rails_ext/*.rb")].each do |path|
  require "rails_ext/#{File.basename(path, ".rb")}"
end
```

### ActiveSupport.on_load Hook

Use hooks to safely extend Rails components:

```ruby
# lib/rails_ext/active_record_date_arithmetic.rb
module ActiveRecordDateArithmetic
  def date_subtract(date_column, seconds_expression)
    case adapter_name
    when "Mysql2", "Trilogy"
      "DATE_SUB(#{date_column}, INTERVAL #{seconds_expression} SECOND)"
    when "PostgreSQL"
      "#{date_column} - INTERVAL '1 second' * #{seconds_expression}"
    when "SQLite"
      "datetime(#{date_column}, '-' || #{seconds_expression} || ' seconds')"
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::AbstractAdapter.include(ActiveRecordDateArithmetic)
end
```

### Prepending vs Including

**Use `prepend` to override existing methods:**

```ruby
# lib/rails_ext/active_storage_suppress_broadcasts.rb
module ActiveStorageAnalyzeJobSuppressBroadcasts
  def perform(blob)
    # Prevent page refreshes during blob analysis
    ApplicationRecord.suppressing_turbo_broadcasts do
      super
    end
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::AnalyzeJob.prepend(ActiveStorageAnalyzeJobSuppressBroadcasts)
end
```

**Use `include` to add new methods:**

```ruby
module Timestampable
  def touch_updated_at
    update_column(:updated_at, Time.current)
  end
end

ActiveRecord::Base.include(Timestampable)
```

### Core Class Extensions

Keep minimal and well-documented:

```ruby
# lib/rails_ext/string.rb
class String
  def all_emoji?
    match?(/\A(\p{Emoji_Presentation}|\p{Extended_Pictographic}|\uFE0F)+\z/u)
  end

  def truncate_words(count, omission: "...")
    words = split
    return self if words.size <= count
    (words[0...count].join(" ") + omission)
  end
end
```

---

## Email Patterns

### ApplicationMailer Base Configuration

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "Fizzy <support@fizzy.do>")

  layout "mailer"
  append_view_path Rails.root.join("app/views/mailers")
  helper :application, :avatars, :html

  private
    # Multi-tenant URL generation
    def default_url_options
      if Current.account
        super.merge(script_name: Current.account.slug)
      else
        super
      end
    end
end
```

### One-Click Unsubscribe Headers (RFC 8058)

```ruby
# app/mailers/concerns/mailers/unsubscribable.rb
module Mailers::Unsubscribable
  extend ActiveSupport::Concern

  included do
    before_action :set_unsubscribe_token
    after_action :set_unsubscribe_headers
  end

  private
    def set_unsubscribe_token
      @unsubscribe_token = @recipient.generate_unsubscribe_token
    end

    def set_unsubscribe_headers
      headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
      headers["List-Unsubscribe"] = "<#{unsubscribe_url}>"
    end

    def unsubscribe_url
      notifications_unsubscribe_url(access_token: @unsubscribe_token)
    end
end
```

### Mailer with Concern

```ruby
# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  include Mailers::Unsubscribable

  def card_updated(notification)
    @notification = notification
    @recipient = notification.user
    @card = notification.source

    mail \
      to: @recipient.email_address,
      subject: "#{@card.title} was updated"
  end

  def bundled_notifications(user:, notifications:)
    @user = user
    @recipient = user
    @notifications = notifications

    mail to: @user.email_address,
         subject: notification_subject
  end

  private
    def notification_subject
      count = @notifications.size
      "You have #{count} new #{'notification'.pluralize(count)}"
    end
end
```

### Email Previews

```ruby
# test/mailers/previews/notification_mailer_preview.rb
class NotificationMailerPreview < ActionMailer::Preview
  def card_updated
    notification = Notification.where(action: "card_updated").first

    NotificationMailer.card_updated(notification)
  end

  def bundled_notifications
    user = User.first
    notifications = user.notifications.undelivered.limit(5)

    NotificationMailer.bundled_notifications(
      user: user,
      notifications: notifications
    )
  end
end

# Access at: http://localhost:3000/rails/mailers
```

---

## File Upload & Storage

### Image Variant Preprocessing

Define variants for consistent image handling:

```ruby
# app/models/concerns/attachments.rb
module Attachments
  extend ActiveSupport::Concern

  # Pre-define variants for eager processing
  VARIANTS = {
    # Use invalid intent to skip GIF-incompatible filtering
    small: { loader: { n: -1 }, resize_to_limit: [800, 600] },
    medium: { loader: { n: -1 }, resize_to_limit: [1200, 900] },
    large: { loader: { n: -1 }, resize_to_limit: [1600, 1200] }
  }.freeze

  included do
    # Process variants after attachment
    after_commit :process_variants, on: [:create, :update], if: :image_attached?
  end

  def process_variants
    return unless image.attached?

    VARIANTS.each_key do |variant_name|
      image.variant(variant_name).processed
    end
  end

  private
    def image_attached?
      saved_change_to_attribute?(:image)
    end
end
```

### Suppress Broadcasts During Analysis

Prevent unnecessary page updates during blob processing:

```ruby
# lib/rails_ext/active_storage_analyze_job_suppress_broadcasts.rb
module ActiveStorageAnalyzeJobSuppressBroadcasts
  def perform(blob)
    # Suppress broadcasts to prevent page refreshing during analysis
    ApplicationRecord.suppressing_turbo_broadcasts do
      super
    end
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::AnalyzeJob.prepend(ActiveStorageAnalyzeJobSuppressBroadcasts)
end
```

### Rich Text Attachment Access

Work with ActionText embeds and attachments:

```ruby
# app/models/card.rb
class Card < ApplicationRecord
  has_rich_text :description

  def attachments
    description&.embeds || []
  end

  def attachment_images
    attachments.select { |a| a.attachable.is_a?(ActiveStorage::Blob) && a.attachable.image? }
  end

  def remote_images
    description&.body&.attachables&.grep(ActionText::Attachables::RemoteImage) || []
  end

  def embedded_videos
    description&.body&.attachables&.select do |a|
      a.is_a?(ActionText::Attachables::ContentAttachment) && a.attachable_type == "Video"
    end
  end
end
```

### File Validation

```ruby
# app/models/card.rb
class Card < ApplicationRecord
  has_one_attached :image

  validate :validate_image_format
  validate :validate_image_size

  private
    def validate_image_format
      return unless image.attached?

      allowed_types = %w[image/jpeg image/png image/gif image/webp]
      unless image.content_type.in?(allowed_types)
        errors.add(:image, "must be a JPEG, PNG, GIF, or WebP")
      end
    end

    def validate_image_size
      return unless image.attached?

      if image.byte_size > 10.megabytes
        errors.add(:image, "must be less than 10MB")
      end
    end
end
```

---

## Current Attributes & Context

### Advanced Current Pattern

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account
  attribute :http_method, :request_id, :user_agent, :ip_address, :referrer

  delegate :identity, to: :session, allow_nil: true

  # Reactive setter - updates user when session/account changes
  def session=(value)
    super(value)
    if value.present? && account.present?
      self.user = identity.users.find_by(account: account)
    end
  end

  def account=(value)
    super(value)
    if session.present? && value.present?
      self.user = identity.users.find_by(account: value)
    end
  end

  # Context switching helpers
  def with_account(value, &block)
    with(account: value, &block)
  end

  def without_account(&block)
    with(account: nil, &block)
  end

  def switch_context(session:, account:)
    self.session = session
    self.account = account
  end
end
```

### Request Context Tracking

Track request metadata for debugging and logging:

```ruby
# app/controllers/concerns/current_request.rb
module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_context
  end

  private
    def set_current_request_context
      Current.http_method = request.method
      Current.request_id = request.uuid
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
      Current.referrer = request.referrer
    end
end

# In ApplicationController
class ApplicationController < ActionController::Base
  include CurrentRequest
end
```

### Background Job Context Preservation

Automatically capture and restore context in jobs:

```ruby
# config/initializers/active_job.rb
module FizzyActiveJobExtensions
  extend ActiveSupport::Concern

  prepended do
    attr_reader :account
    self.enqueue_after_transaction_commit = true
  end

  def initialize(...)
    super
    @account = Current.account
  end

  def serialize
    super.merge("account" => @account&.to_gid)
  end

  def deserialize(job_data)
    super
    if account_gid = job_data["account"]
      @account = GlobalID::Locator.locate(account_gid)
    end
  end

  def perform_now
    if account.present?
      Current.with_account(account) { super }
    else
      super
    end
  end
end

ActiveSupport.on_load(:active_job) do
  prepend FizzyActiveJobExtensions
end
```

---

## Routing Conventions

### scope module vs namespace

```ruby
# config/routes.rb

# Use scope module: to avoid nesting URLs but organize controllers
resources :boards do
  scope module: :boards do
    resource :publication    # /boards/:board_id/publication
    resource :entropy        # Boards::PublicationController
    resources :columns
  end
end

# Use namespace for both URL and controller organization
namespace :admin do
  resources :accounts        # /admin/accounts → Admin::AccountsController
  resources :users
end

# Nested namespace for complex organization
namespace :api do
  namespace :v1 do
    resources :cards         # /api/v1/cards → Api::V1::CardsController
  end
end
```

### Singular Resources

Use for one-per-parent resources:

```ruby
resources :boards do
  resource :publication      # No :id needed
  resource :entropy
  resource :subscription
end

# Generates routes:
# POST   /boards/:board_id/publication
# GET    /boards/:board_id/publication/edit
# PATCH  /boards/:board_id/publication
# DELETE /boards/:board_id/publication
```

### Deep Nesting Organization

For complex nested resources:

```ruby
resources :boards do
  scope module: :boards do
    resources :columns do
      scope module: :columns do
        resources :cards do
          scope module: :cards do
            namespace :drops do
              resource :not_now
              resource :closure
            end
          end
        end
      end
    end
  end
end

# URL: /boards/:board_id/columns/:column_id/cards/:card_id/drops/not_now
# Controller: Boards::Columns::Cards::Drops::NotNowsController
```

---

## Configuration & Environment

### Application Configuration

```ruby
# config/application.rb
module Fizzy
  class Application < Rails::Application
    config.load_defaults 8.0

    # Autoload configuration
    config.autoload_lib(ignore: %w[assets tasks rails_ext])

    # Generator defaults
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :test_unit, fixture: true
      g.system_tests :test_unit
    end

    # Active Job configuration
    config.active_job.queue_adapter = :solid_queue
    config.active_job.enqueue_after_transaction_commit = :default

    # Eager load custom paths in production
    config.eager_load_paths << Rails.root.join("lib")
  end
end
```

### Environment Detection

```ruby
# lib/fizzy.rb
module Fizzy
  def self.saas?
    return @saas if defined?(@saas)
    @saas = !!(ENV["SAAS"] == "true" || File.exist?(Rails.root.join("tmp/saas.txt")))
  end

  def self.local?
    Rails.env.development? || Rails.env.test?
  end

  def self.db_adapter
    @db_adapter ||= begin
      adapter_name = ENV.fetch("DATABASE_ADAPTER", saas? ? "mysql" : "sqlite")
      DbAdapter.new(adapter_name)
    end
  end
end
```

### Credentials Management

```ruby
# Access credentials
Rails.application.credentials.dig(:aws, :access_key_id)
Rails.application.credentials.openai_api_key

# Environment-specific credentials
Rails.application.credentials.dig(:production, :secret_key_base)

# In production.rb
config.require_master_key = true
```

### Environment Variables

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.log_level = ENV.fetch("LOG_LEVEL", "info")

  config.action_mailer.smtp_settings = {
    address: ENV["SMTP_ADDRESS"],
    port: ENV.fetch("SMTP_PORT", 587),
    domain: ENV["SMTP_DOMAIN"],
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: :plain,
    enable_starttls_auto: true
  }
end
```

---

## Deployment & DevOps

### Kamal Configuration

```yaml
# config/deploy.yml
service: fizzy
image: your-org/fizzy

proxy:
  ssl: true
  host: fizzy.example.com
  app_port: 3000

env:
  secret:
    - SECRET_KEY_BASE
    - RAILS_MASTER_KEY
    - SMTP_PASSWORD
    - VAPID_PRIVATE_KEY
  clear:
    RAILS_ENV: production
    SOLID_QUEUE_IN_PUMA: true
    MAILER_FROM_ADDRESS: support@fizzy.example.com

volumes:
  - "fizzy_storage:/rails/storage"
  - "fizzy_db:/rails/db"

aliases:
  console: app exec --interactive --reuse "bin/rails console"
  shell: app exec --interactive --reuse "bash"
  dbc: app exec --interactive --reuse "bin/rails dbconsole"
  logs: app logs --follow

healthcheck:
  path: /up
  interval: 10s
```

### Health Check Endpoint

```ruby
# config/routes.rb
get "/up", to: "health#show"

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :require_authentication

  def show
    # Check database connectivity
    ActiveRecord::Base.connection.execute("SELECT 1")

    # Check storage
    raise unless ActiveStorage::Blob.service.exist?("health_check.txt")

    render plain: "OK", status: :ok
  rescue => e
    render plain: "ERROR: #{e.message}", status: :service_unavailable
  end
end
```

### Zero-Downtime Migration Strategy

```ruby
# config/initializers/strong_migrations.rb
StrongMigrations.start_after = 20240101000000
StrongMigrations.auto_analyze = true
StrongMigrations.target_version = 8.0
StrongMigrations.check_down = true

# Enforce safe migrations:
# - Add columns with defaults in multiple steps
# - Add indexes concurrently
# - Backfill data before adding NOT NULL constraints
```

### Deployment Commands

```bash
# Deploy to production
kamal deploy

# Run console on production
kamal console

# View logs
kamal logs

# Run migrations
kamal app exec "bin/rails db:migrate"

# Rollback
kamal rollback
```

---

## Infrastructure Checklist

### Before Deployment

**Configuration:**
- [ ] All secrets in Rails credentials or environment variables
- [ ] Sensitive parameters filtered from logs
- [ ] Database credentials secured
- [ ] SMTP settings configured
- [ ] Storage buckets configured (S3, etc.)

**Rails Extensions:**
- [ ] Extensions in `lib/rails_ext/` auto-loaded
- [ ] Use `ActiveSupport.on_load` hooks
- [ ] Core class extensions are minimal
- [ ] Prepend/include used correctly

**Email:**
- [ ] ApplicationMailer configured with defaults
- [ ] One-click unsubscribe headers set
- [ ] Multi-tenant URLs handled correctly
- [ ] Email previews created for testing

**Files:**
- [ ] Image variants pre-defined
- [ ] File validations in place
- [ ] Broadcast suppression during analysis
- [ ] Storage service configured (S3/local)

**Deployment:**
- [ ] Health check endpoint working
- [ ] Kamal configuration complete
- [ ] Secrets properly configured
- [ ] Volume mounts defined
- [ ] Zero-downtime migrations enabled

---

## Related Guides

- [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) - Models, controllers, security
- [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md) - Views, Turbo, Stimulus, CSS
- [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) - Complete reference
- [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) - Top 20 patterns

---

**Remember:** Automate everything, monitor closely, deploy fearlessly! 🚀
