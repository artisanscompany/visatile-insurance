# Backend Development Guide

> **Models, Controllers, Security, Database & Jobs** - Backend patterns from the 37signals Fizzy codebase

This guide covers server-side Rails development. For frontend patterns, see [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md). For infrastructure, see [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md).

---

## Table of Contents

1. [Model Patterns](#model-patterns)
2. [Controller Patterns](#controller-patterns)
3. [Security Patterns](#security-patterns)
4. [Database & Query Patterns](#database--query-patterns)
5. [Background Jobs](#background-jobs)
6. [Form Objects & POROs](#form-objects--poros)
7. [Backend Checklist](#backend-checklist)

---

## Model Patterns

### Model Structure (Always Follow This Order)

```ruby
class Card < ApplicationRecord
  # 1. Concerns - Alphabetically ordered
  include Assignable, Attachable, Closeable, Eventable, Searchable

  # 2. Associations with defaults
  belongs_to :account, default: -> { board.account }
  belongs_to :board
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  has_many :comments, dependent: :destroy
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy
  has_one_attached :image, dependent: :purge_later
  has_rich_text :description

  # 3. Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :number, presence: true, uniqueness: { scope: :account_id }

  # 4. Callbacks - Ordered by lifecycle
  before_validation :set_default_title, if: :new_record?
  before_create :assign_number
  after_save -> { board.touch }, if: :published?
  after_update :handle_board_change, if: :saved_change_to_board_id?

  # 5. Scopes
  scope :active, -> { where(status: :active) }
  scope :recent, -> { where("created_at >= ?", 30.days.ago) }
  scope :preloaded, -> { preload(:creator, :tags, board: :columns) }

  # 6. Delegations
  delegate :accessible_to?, to: :board

  # 7. Public methods
  def close(user:)
    update!(status: :closed, closed_at: Time.current)
    track_event(:closed, creator: user)
  end

  # 8. Private methods
  private
    def set_default_title
      self.title = "Untitled" if title.blank?
    end
end
```

### Concern Pattern

Extract cohesive behavior into focused concerns:

```ruby
# app/models/card/eventable.rb
module Card::Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
    after_create_commit :track_creation_event
  end

  class_methods do
    def with_recent_events
      includes(:events).where(events: { created_at: 7.days.ago.. })
    end
  end

  def track_event(action, creator: Current.user, **particulars)
    return unless should_track_event?

    events.create!(
      action: "card_#{action}",
      creator: creator,
      board: board,
      particulars: particulars
    )
  end

  private
    def should_track_event?
      persisted? && !destroyed?
    end

    def track_creation_event
      track_event(:created)
    end
end
```

**When to Extract a Concern:**
- ✅ Behavior used by multiple models
- ✅ Distinct aspect of model (Searchable, Eventable, Broadcastable)
- ✅ Makes model easier to understand
- ❌ Only used in one place
- ❌ Just to make file smaller

### Association Patterns

```ruby
# Dynamic defaults using lambdas
belongs_to :account, default: -> { board.account }
belongs_to :creator, class_name: "User", default: -> { Current.user }

# Rich association extensions
has_many :accesses, dependent: :delete_all do
  def revise(granted: [], revoked: [])
    transaction do
      grant_to granted
      revoke_from revoked
    end
  end

  def grant_to(users)
    Array(users).each { |u| create!(user: u) unless exists?(user: u) }
  end
end

# Always specify dependent behavior
has_many :comments, dependent: :destroy        # Callbacks run
has_many :accesses, dependent: :delete_all     # Fast, no callbacks
has_one_attached :image, dependent: :purge_later  # Async cleanup
```

### Multi-Tenancy with Current Attributes

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account
  attribute :request_id, :user_agent, :ip_address

  # Reactive setters
  def session=(value)
    super(value)
    if value.present? && account.present?
      self.user = session.identity.users.find_by(account: account)
    end
  end

  # Context switching helpers
  def with_account(value, &block)
    with(account: value, &block)
  end
end

# Every model includes account_id for tenant isolation
class Card < ApplicationRecord
  belongs_to :account

  scope :in_current_account, -> { where(account: Current.account) }
end
```

### Query Optimization

```ruby
# Chainable scopes
scope :active, -> { where(status: :active) }
scope :recent, -> { where("created_at >= ?", 30.days.ago) }
scope :tagged_with, ->(tag_ids) do
  joins(:taggings).where(taggings: { tag_id: tag_ids }).distinct
end

# Preloading scope
scope :preloaded, -> do
  with_users.preload(
    :column, :tags, :steps, :closure,
    board: [:entropy, :columns]
  ).with_rich_text_description_and_embeds
end

scope :with_users, -> do
  preload(creator: [:avatar_attachment, :account])
end

# Usage
cards = Card.active.recent.tagged_with([1, 2]).preloaded
```

---

## Controller Patterns

### RESTful Resource Design

**NEVER add custom actions** - create new resources instead:

```ruby
# ❌ BAD
resources :cards do
  post :close
  post :reopen
  post :assign
end

# ✅ GOOD
resources :cards do
  resource :closure      # POST creates, DELETE destroys
  resource :assignment
  resource :pin
end
```

### Thin Controllers

```ruby
class Cards::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close(user: Current.user)
    render_card_replacement
  end

  def destroy
    @card.reopen(user: Current.user)
    render_card_replacement
  end
end

# Logic lives in the model
class Card < ApplicationRecord
  def close(user:)
    transaction do
      update!(status: :closed, closed_at: Time.current)
      track_event(:closed, creator: user)
      notify_watchers
    end
  end

  def reopen(user:)
    update!(status: :active, closed_at: nil)
    track_event(:reopened, creator: user)
  end
end
```

### Controller Concerns

```ruby
# app/controllers/concerns/card_scoped.rb
module CardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_card, :set_board
  end

  private
    def set_card
      @card = Current.user.accessible_cards.find_by!(number: params[:card_id])
    end

    def set_board
      @board = @card.board
    end

    def render_card_replacement
      render turbo_stream: turbo_stream.replace(
        dom_id(@card, :card_container),
        partial: "cards/container",
        method: :morph,
        locals: { card: @card.reload }
      )
    end
end
```

### Strong Parameters

```ruby
# Rails 8 params.expect
def card_params
  params.expect(card: [ :title, :description, :status, tag_ids: [] ])
end

# With nested hashes
def board_params
  params.expect(board: [ :name, :all_access, entropy: [ :auto_postpone_period ] ])
end
```

### Authorization

```ruby
# In controller
before_action :ensure_can_edit_card, only: %i[ update destroy ]

private
  def ensure_can_edit_card
    head :forbidden unless @card.editable_by?(Current.user)
  end

# Authorization logic in model
class Card < ApplicationRecord
  def editable_by?(user)
    user.admin? || user.owner? || creator == user
  end
end
```

---

## Security Patterns

### CSRF Protection

```ruby
# app/controllers/concerns/request_forgery_protection.rb
module RequestForgeryProtection
  extend ActiveSupport::Concern

  private
    def verified_request?
      super || safe_fetch_site?
    end

    def safe_fetch_site?
      %w[same-origin same-site].include?(
        request.headers["Sec-Fetch-Site"].to_s.downcase
      )
    end
end
```

### SQL Injection Prevention

```ruby
# ✅ GOOD - Parameterized
Card.where("title LIKE ?", "%#{sanitized}%")
Card.where(status: params[:status])

# ✅ GOOD - Named placeholders
Card.where("title = :title AND status = :status",
  title: params[:title],
  status: params[:status]
)

# ❌ BAD - String interpolation
Card.where("title LIKE '%#{params[:term]}%'")
```

### XSS Prevention

```erb
<!-- ✅ GOOD - Auto-escaped -->
<%= @card.title %>
<%= simple_format(@card.description) %>

<!-- ✅ GOOD - Sanitized rich text -->
<%= @card.description %>  <!-- ActionText sanitizes -->

<!-- ❌ BAD - Raw user input -->
<%= raw @user_input %>
<%= @content.html_safe %>
```

### Secure Sessions

```ruby
def set_current_session(session)
  Current.session = session

  cookies.signed.permanent[:session_token] = {
    value: session.signed_id,
    httponly: true,                    # Prevent JS access
    secure: Rails.env.production?,     # HTTPS only
    same_site: :lax                    # CSRF protection
  }
end
```

### Parameter Filtering

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += %i[
  passw password password_confirmation
  secret token _key crypt salt
  otp ssn cvv
]
```

---

## Database & Query Patterns

### Migration Style

```ruby
class AddNumberToCards < ActiveRecord::Migration[8.2]
  def change
    add_column :cards, :number, :bigint, null: false
    add_column :accounts, :cards_count, :bigint, default: 0, null: false
    add_index :cards, [:account_id, :number], unique: true
  end
end
```

### Schema Conventions

```ruby
create_table :cards, id: :uuid do |t|
  t.uuid :account_id, null: false          # Tenant isolation
  t.uuid :board_id, null: false
  t.bigint :number, null: false            # Sequential within account

  t.string :title, null: false
  t.string :status, default: "active", null: false

  t.timestamps

  t.index [:account_id, :number], unique: true
  t.index :board_id
  t.index [:status, :last_active_at]      # Composite for queries
end
```

### Query Optimization

```ruby
# Preload associations
scope :preloaded, -> do
  with_users.preload(:column, :tags, board: :columns)
end

# Use find_each for batching
Card.active.find_each do |card|
  card.update_search_index
end

# NOT Card.active.each - loads all into memory
```

---

## Background Jobs

### Job Pattern

Jobs are thin wrappers that delegate to models:

```ruby
# Model concern
module Event::Relaying
  extend ActiveSupport::Concern

  included do
    after_create_commit :relay_later
  end

  def relay_later
    Event::RelayJob.perform_later(self)
  end

  def relay_now
    webhooks.each { |wh| wh.deliver(event: self) }
  end
end

# Job
class Event::RelayJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.relay_now
  end
end
```

### Multi-Tenant Context in Jobs

```ruby
# config/initializers/active_job.rb
module FizzyActiveJobExtensions
  extend ActiveSupport::Concern

  prepended do
    attr_reader :account
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
    @account = GlobalID::Locator.locate(job_data["account"]) if job_data["account"]
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

## Form Objects & POROs

### When to Use Form Objects

✅ **DO use when:**
- Form spans multiple models
- Complex validation logic
- Non-database-backed forms
- Multi-step processes

❌ **DON'T use when:**
- Simple CRUD operations
- Single model with standard validations

### Form Object Pattern

```ruby
# app/models/signup.rb
class Signup
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :full_name, :string
  attribute :email_address, :string

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Context-specific validations
  with_options on: :completion do
    validates_presence_of :full_name
  end

  def complete
    return false unless valid?(:completion)

    begin
      Account.transaction do
        create_account_and_user
      end
      true
    rescue => error
      cleanup_on_failure
      handle_error(error)
      false
    end
  end

  private
    def create_account_and_user
      @account = Account.create!(name: account_name)
      @user = @account.users.create!(
        name: full_name,
        email: email_address,
        role: :owner
      )
    end

    def handle_error(error)
      errors.add(:base, "Something went wrong")
      Rails.error.report(error, severity: :error)
    end
end
```

---

## Backend Checklist

### Before Every Commit

**Models:**
- [ ] Concerns → Associations → Validations → Callbacks → Scopes
- [ ] Methods ordered by invocation flow
- [ ] Private methods indented under `private`
- [ ] All associations have `dependent:` option

**Controllers:**
- [ ] RESTful resources only (no custom actions)
- [ ] Logic delegated to models
- [ ] Strong parameters with `params.expect`
- [ ] Authorization checks in place

**Security:**
- [ ] Parameterized queries (no string interpolation)
- [ ] User content escaped in views
- [ ] Sensitive params filtered
- [ ] Secure session cookies

**Database:**
- [ ] Migrations are reversible
- [ ] Indexes on foreign keys
- [ ] `null: false` with sensible defaults
- [ ] Preload associations to avoid N+1

**Jobs:**
- [ ] Logic in models, jobs delegate
- [ ] Use `_later` / `_now` suffix convention
- [ ] Account context preserved

---

## Related Guides

- [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md) - Views, Turbo, Stimulus, CSS
- [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md) - Deployment, config, email
- [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) - Complete reference
- [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) - Top 20 patterns

---

**Remember:** Rich models, thin controllers, security by default! 🔒
