# 37signals Rails Coding Standards & Best Practices

> **Based on the Fizzy codebase** - A comprehensive guide to writing clean, maintainable Rails code following 37signals conventions.

---

## Table of Contents

### Core Concepts
1. [Core Philosophy](#core-philosophy)
2. [Application Structure & Organization](#application-structure--organization)

### Backend Patterns
3. [Model Patterns](#model-patterns)
4. [Controller Patterns](#controller-patterns)
5. [Security Patterns](#security-patterns)
6. [Database & Query Patterns](#database--query-patterns)
7. [Background Jobs](#background-jobs)
8. [Form Objects & POROs](#form-objects--poros)

### Frontend Patterns
9. [View & Frontend Patterns](#view--frontend-patterns)
10. [Helper Patterns](#helper-patterns)
11. [Turbo & Real-time Updates](#turbo--real-time-updates)
12. [Stimulus Advanced Patterns](#stimulus-advanced-patterns)
13. [CSS Architecture](#css-architecture)

### Infrastructure & Configuration
14. [Rails Extensions & Monkey Patching](#rails-extensions--monkey-patching)
15. [Email Patterns](#email-patterns)
16. [File Upload & Storage](#file-upload--storage)
17. [Current Attributes & Context](#current-attributes--context)
18. [Routing Conventions](#routing-conventions)
19. [Configuration & Environment](#configuration--environment)
20. [Deployment & DevOps](#deployment--devops)

### Testing & Quality
21. [Testing Patterns](#testing-patterns)
22. [Code Style & Conventions](#code-style--conventions)

### Reference
23. [Quick Reference](#quick-reference)

---

## Core Philosophy

### Vanilla Rails First

Embrace Rails conventions and avoid over-architecting. The framework provides everything you need for most applications.

**Key Principles:**

1. **Rich Models, Thin Controllers** - Business logic lives in models and concerns, controllers coordinate
2. **Domain-Driven Organization** - Organize by business domain, not technical layers
3. **RESTful Design** - Create new resources instead of custom controller actions
4. **Explicit Over Implicit** - Clear, readable code beats clever tricks
5. **Concerns for Composition** - Small, focused mixins to compose behavior
6. **Modern Rails Features** - Leverage Turbo, Stimulus, and Hotwire
7. **Intention-Revealing Names** - Names should clearly express purpose
8. **Test Everything** - Comprehensive testing at all levels

---

## Application Structure & Organization

### Directory Organization

Organize code by **domain**, not by technical layer. Related functionality lives together.

```
app/
├── controllers/
│   ├── boards_controller.rb          # Top-level resource
│   ├── cards/                          # Nested namespace for card sub-resources
│   │   ├── comments_controller.rb
│   │   ├── closures_controller.rb
│   │   └── assignments_controller.rb
│   └── concerns/                       # Shared controller behavior
│       ├── authenticated.rb
│       └── card_scoped.rb
├── models/
│   ├── card.rb                         # Main model
│   ├── card/                           # Model-specific concerns
│   │   ├── entropic.rb
│   │   ├── eventable.rb
│   │   └── postponable.rb
│   └── concerns/                       # Shared model concerns
│       └── searchable.rb
├── jobs/
│   ├── card/                           # Namespaced by domain
│   │   └── auto_postpone_job.rb
│   └── event/
│       └── relay_job.rb
└── views/
    ├── boards/
    │   ├── show.html.erb
    │   └── show/                       # Nested partials for specific view
    │       ├── _columns.html.erb
    │       └── _filters.html.erb
    └── cards/
        ├── show.html.erb
        └── show/
            ├── _activity.html.erb
            └── _meta.html.erb
```

### Naming Conventions

- **Namespaced Controllers**: `Cards::CommentsController` (not `CardCommentsController`)
- **Namespaced Models**: `Card::Entropic` for model-specific concerns
- **Nested Partials**: `boards/show/_columns.html.erb` (partials related to specific view)
- **Jobs**: `Card::AutoPostponeJob` (namespaced by domain)

### When to Namespace

**DO namespace when:**
- Creating sub-resources of a parent (e.g., `Cards::CommentsController`)
- Grouping domain-specific concerns (e.g., `Card::Eventable`)
- Organizing complex features (e.g., `Search::CardIndex`, `Search::Shard`)

**DON'T namespace when:**
- It's a top-level resource (e.g., `BoardsController`, not `Boards::BoardsController`)
- The concept stands alone (e.g., `User`, not `Account::User`)

---

## Model Patterns

### Model Structure

Models should follow this consistent structure:

```ruby
class Card < ApplicationRecord
  # 1. Concerns - Alphabetically ordered
  include Assignable, Attachable, Broadcastable, Closeable, Colored, Entropic,
    Eventable, Exportable, Golden, Mentions, Multistep, Pinnable, Postponable,
    Promptable, Readable, Searchable, Stallable, Statuses, Taggable,
    Triageable, Watchable

  # 2. Associations with defaults
  belongs_to :account, default: -> { board.account }
  belongs_to :board
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  has_many :comments, dependent: :destroy
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :card
  has_one_attached :image, dependent: :purge_later
  has_rich_text :description

  # 3. Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :number, presence: true, uniqueness: { scope: :account_id }

  # 4. Callbacks - Ordered: before_validation, before_save, before_create, after_save, after_create, etc.
  before_validation :set_default_title, if: :new_record?
  before_create :assign_number
  after_save -> { board.touch }, if: :published?
  after_update :handle_board_change, if: :saved_change_to_board_id?

  # 5. Scopes
  scope :reverse_chronologically, -> { order created_at: :desc, id: :desc }
  scope :latest, -> { order last_active_at: :desc, id: :desc }
  scope :with_users, -> { preload(creator: [:avatar_attachment, :account]) }

  # Parameterized scopes using case statements
  scope :indexed_by, ->(index) do
    case index
    when "stalled" then stalled
    when "closed" then closed
    when "not_now" then postponed
    else active
    end
  end

  # 6. Delegations
  delegate :accessible_to?, to: :board
  delegate :auto_postpone_period, to: :board

  # 7. Public methods
  def move_to(new_board)
    transaction do
      update!(board: new_board)
      events.update_all(board_id: new_board.id)
    end
  end

  def assigned_to?(user)
    assignees.include?(user)
  end

  # 8. Private methods
  private
    def set_default_title
      self.title = "Untitled" if title.blank?
    end

    def assign_number
      self.number = account.increment!(:cards_count).cards_count
    end
end
```

### Concern Pattern

Use concerns to compose behavior. Each concern should be **focused and single-purpose**.

**Good Concern Structure:**

```ruby
module Card::Entropic
  extend ActiveSupport::Concern

  included do
    # Scopes, callbacks, validations in included block
    scope :due_to_be_postponed, -> do
      active.joins(board: :account)
        .left_outer_joins(board: :entropy)
        .where("cards.last_active_at <= ?", Time.now - auto_postpone_period)
    end

    delegate :auto_postpone_period, to: :board
  end

  # Class methods
  class_methods do
    def auto_postpone_all_due
      due_to_be_postponed.find_each do |card|
        card.auto_postpone(user: card.account.system_user)
      end
    end
  end

  # Instance methods
  def entropic?
    auto_postpone_period.present?
  end

  def auto_postpone(user:)
    postpone(user: user, reason: :entropy)
    track_event(:auto_postponed, creator: user)
  end
end
```

**When to Extract a Concern:**

✅ **DO extract when:**
- A cohesive set of methods is used by multiple models
- A model has distinct behavioral aspects (e.g., `Eventable`, `Searchable`)
- The concern makes the model easier to understand

❌ **DON'T extract when:**
- It's only used in one place
- It's just to make a large file smaller (organize differently instead)
- The methods don't form a cohesive unit

### Association Patterns

**Use lambda syntax for dynamic defaults:**

```ruby
# GOOD - Dynamic default based on associated record
belongs_to :account, default: -> { board.account }
belongs_to :creator, class_name: "User", default: -> { Current.user }

# BAD - Static default
belongs_to :creator, class_name: "User", default: User.first
```

**Rich Association Extensions:**

Extend associations with custom methods inline for domain-specific behavior:

```ruby
has_many :accesses, dependent: :delete_all do
  def revise(granted: [], revoked: [])
    transaction do
      grant_to granted
      revoke_from revoked
    end
  end

  def grant_to(users)
    Array(users).each do |user|
      create!(user: user) unless exists?(user: user)
    end
  end

  def revoke_from(users)
    where(user: users).delete_all
  end
end

# Usage:
board.accesses.revise(granted: [user1, user2], revoked: [user3])
```

**Dependent Actions:**

Always specify what happens when parent is destroyed:

```ruby
has_many :comments, dependent: :destroy        # Destroy children
has_many :accesses, dependent: :delete_all     # Delete without callbacks (faster)
has_one_attached :image, dependent: :purge_later  # Async cleanup
```

### Multi-Tenancy Pattern

Use a `Current` context object to manage tenant isolation:

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account
  attribute :http_method, :request_id, :user_agent, :ip_address

  delegate :identity, to: :session, allow_nil: true

  def session=(value)
    super(value)
    if value.present? && account.present?
      self.user = identity.users.find_by(account: account)
    end
  end
end
```

**Every model includes `account_id`:**

```ruby
class Card < ApplicationRecord
  belongs_to :account

  # All queries scoped to current account
  scope :in_current_account, -> { where(account: Current.account) }
end

# In controllers/middleware, set the current account:
Current.account = Account.find_by!(external_account_id: params[:account_id])
```

### Event Tracking Pattern

Track domain events using a clean, reusable concern:

```ruby
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  def track_event(action, creator: Current.user, board: self.board, **particulars)
    return unless should_track_event?

    board.events.create!(
      action: "#{eventable_prefix}_#{action}",
      creator: creator,
      board: board,
      eventable: self,
      particulars: particulars
    )
  end

  private
    def should_track_event?
      persisted? && !destroyed?
    end

    def eventable_prefix
      self.class.name.demodulize.underscore
    end
end

# Usage in models:
class Card < ApplicationRecord
  include Eventable

  def close(user:)
    update!(status: :closed, closed_at: Time.current)
    track_event(:closed, creator: user)
  end
end
```

### Query Patterns

**Chainable Scopes:**

Build complex queries with composable scopes:

```ruby
class Card < ApplicationRecord
  scope :active, -> { where(status: :active) }
  scope :closed, -> { where(status: :closed) }
  scope :postponed, -> { where(status: :not_now) }

  scope :recent, -> { where("created_at >= ?", 30.days.ago) }
  scope :stale, -> { where("last_active_at <= ?", 7.days.ago) }

  scope :tagged_with, ->(tag_ids) do
    joins(:taggings).where(taggings: { tag_id: tag_ids }).distinct
  end

  scope :preloaded, -> do
    with_users.preload(
      :column, :tags, :steps, :closure,
      board: [:entropy, :columns]
    ).with_rich_text_description_and_embeds
  end
end

# Usage - scopes chain beautifully:
Card.active.recent.tagged_with([tag1.id, tag2.id]).preloaded
```

**Avoid N+1 Queries:**

```ruby
# BAD - N+1 query
cards.each do |card|
  card.creator.name  # Queries for each card
end

# GOOD - Preload associations
cards.preload(:creator).each do |card|
  card.creator.name  # No extra queries
end

# GOOD - Use includes for filtering
cards.includes(:creator).where(users: { role: :admin })
```

---

## Controller Patterns

### Controller Structure

Controllers should be **thin** and delegate to rich domain models.

```ruby
class BoardsController < ApplicationController
  include FilterScoped

  # Set up data before actions
  before_action :set_board, except: %i[ new create ]
  before_action :ensure_permission_to_admin_board, only: %i[ update destroy ]

  def show
    if @filter.used?(ignore_boards: true)
      show_filtered_cards
    else
      show_columns
    end
  end

  def create
    @board = Board.create! board_params.with_defaults(all_access: true)
    redirect_to board_path(@board)
  end

  def update
    @board.update! board_params
    @board.accesses.revise granted: grantees, revoked: revokees if grantees_changed?

    if @board.accessible_to?(Current.user)
      redirect_to edit_board_path(@board), notice: "Saved"
    else
      redirect_to root_path, notice: "Saved (you were removed from the board)"
    end
  end

  private
    def set_board
      @board = Current.user.boards.find params[:id]
    end

    def board_params
      params.expect(board: [ :name, :all_access, :auto_postpone_period ])
    end

    def grantees
      @board.account.users.active.where id: grantee_ids
    end

    def grantees_changed?
      params[:user_ids].present?
    end
end
```

### RESTful Resource Design

**NEVER add custom actions** - create new resources instead.

```ruby
# ❌ BAD - Custom actions
resources :cards do
  post :close
  post :reopen
  post :assign
end

# ✅ GOOD - New resources
resources :cards do
  resource :closure           # POST creates, DELETE destroys
  resource :assignment        # PATCH/PUT toggles
  resource :pin               # POST creates, DELETE destroys
end
```

**Implementation:**

```ruby
# app/controllers/cards/closures_controller.rb
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
```

**Routes:**

```ruby
resources :cards do
  scope module: :cards do
    resource :closure      # Singular for single resource
    resource :goldness
    resource :pin

    resources :comments    # Plural for collections
    resources :steps
  end
end
```

### Controller Concerns

Extract common setup logic into concerns:

```ruby
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

# Usage in multiple controllers:
class Cards::CommentsController < ApplicationController
  include CardScoped

  def create
    @comment = @card.comments.create!(comment_params)
    # @card and @board are already set
  end
end
```

### Strong Parameters

Use Rails 8's `params.expect` for parameter filtering:

```ruby
# Simple params
def card_params
  params.expect(card: [ :status, :title, :description, :image ])
end

# With nested arrays
def card_params
  params.expect(card: [ :title, :description, tag_ids: [] ])
end

# With nested hashes
def board_params
  params.expect(board: [ :name, :all_access, entropy: [ :auto_postpone_period ] ])
end
```

### Authorization Pattern

Keep authorization **simple and explicit**:

```ruby
# In controller
before_action :ensure_permission_to_admin_board, only: %i[ update destroy ]

private
  def ensure_permission_to_admin_board
    head :forbidden unless Current.user.can_administer_board?(@board)
  end

  def ensure_permission_to_edit_card
    head :forbidden unless @card.editable_by?(Current.user)
  end
```

**Authorization logic lives in models:**

```ruby
class Board < ApplicationRecord
  def accessible_to?(user)
    all_access? || accesses.exists?(user: user)
  end
end

class User < ApplicationRecord
  def can_administer_board?(board)
    owner? || admin? || board.created_by?(self)
  end
end
```

---

## Security Patterns

Security is paramount when building multi-tenant applications. Follow these patterns to keep your application secure.

### CSRF Protection

Rails provides CSRF protection by default, but enhance it with modern browser headers:

```ruby
# app/controllers/concerns/request_forgery_protection.rb
module RequestForgeryProtection
  extend ActiveSupport::Concern

  included do
    after_action :append_sec_fetch_site_to_vary_header
  end

  private
    def verified_request?
      super || safe_fetch_site?
    end

    SAFE_FETCH_SITES = %w[ same-origin same-site ]

    def safe_fetch_site?
      SAFE_FETCH_SITES.include?(sec_fetch_site_value)
    end

    def sec_fetch_site_value
      request.headers["Sec-Fetch-Site"].to_s.downcase
    end

    def append_sec_fetch_site_to_vary_header
      response.headers["Vary"] = [response.headers["Vary"], "Sec-Fetch-Site"].compact.join(", ")
    end
end
```

### HTML Sanitization

Configure ActionText/Trix allowed tags and attributes for rich content:

```ruby
# config/initializers/sanitization.rb
Rails.application.config.after_initialize do
  # Add allowed tags
  Rails::HTML5::SafeListSanitizer.allowed_tags.merge(%w[
    s table tr td th thead tbody tfoot caption
    details summary video source audio track
  ])

  # Add allowed attributes (including data attributes for Stimulus/Turbo)
  Rails::HTML5::SafeListSanitizer.allowed_attributes.merge(%w[
    data-turbo-frame data-controller data-action data-target
    controls type width height autoplay loop muted
    data-lightbox-target data-lightbox-url-value
  ])
end
```

### Sensitive Parameter Filtering

Filter sensitive data from logs and error reports:

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += %i[
  passw password password_confirmation
  secret token _key crypt salt certificate
  otp ssn cvv card_number
]

# For custom filtering in specific contexts:
Rails.application.config.filter_parameters << lambda do |key, value|
  value.replace("[FILTERED]") if key == "credit_card" && value.is_a?(String)
end
```

### Secure Session Management

Implement secure, httponly cookies with proper expiration:

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  private
    def authenticate
      if session = Session.find_by_token(cookies.signed[:session_token])
        Current.session = session
      else
        redirect_to sign_in_path
      end
    end

    def set_current_session(session)
      Current.session = session
      cookies.signed.permanent[:session_token] = {
        value: session.signed_id,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
    end

    def end_current_session
      Current.session&.destroy
      cookies.delete(:session_token)
    end
end
```

### Authorization Helpers

Create simple, explicit authorization methods:

```ruby
# app/controllers/concerns/authorization.rb
module Authorization
  extend ActiveSupport::Concern

  private
    def ensure_admin
      head :forbidden unless Current.user.admin?
    end

    def ensure_owner_or_admin
      head :forbidden unless Current.user.owner? || Current.user.admin?
    end

    def ensure_staff
      head :forbidden unless Current.identity.staff?
    end

    # Environment-specific access control
    def ensure_only_staff_can_access_non_production
      return if Rails.env.local? || Rails.env.production?
      head :forbidden unless Current.identity.staff?
    end

    # Resource-specific authorization
    def ensure_can_edit_card
      head :forbidden unless @card.editable_by?(Current.user)
    end
end
```

### SQL Injection Prevention

Always use parameterized queries:

```ruby
# ✅ GOOD - Parameterized query
Card.where("title LIKE ?", "%#{sanitized_term}%")
Card.where(status: params[:status])

# ✅ GOOD - Using Arel for complex queries
cards_table = Card.arel_table
Card.where(cards_table[:title].matches("%#{sanitized_term}%"))

# ❌ BAD - String interpolation (SQL injection risk!)
Card.where("title LIKE '%#{params[:term]}%'")
```

### XSS Protection

Escape user content by default, use `html_safe` judiciously:

```ruby
# ✅ GOOD - Auto-escaped
<%= @card.title %>
<%= simple_format(@card.description) %>

# ✅ GOOD - Sanitized rich text
<%= @card.description %>  # ActionText content is sanitized

# ⚠️ USE WITH CAUTION - Only for trusted, sanitized HTML
<%= sanitize(@card.description, tags: %w[p br strong em]) %>
<%= @trusted_html.html_safe %>

# ❌ BAD - Raw user input
<%= raw @card.title %>
<%= @user_input.html_safe %>
```

### Development-Only Security Guards

Prevent security issues from leaking into production:

```ruby
# app/controllers/sessions_controller.rb
def create
  # ... magic link logic ...

  if Rails.env.development?
    flash[:magic_link_code] = magic_link.code  # Show code in dev
  end

  ensure_development_magic_link_not_leaked
end

private
  def ensure_development_magic_link_not_leaked
    unless Rails.env.development?
      raise "Leaking magic link via flash in #{Rails.env}?" if flash[:magic_link_code].present?
    end
  end
```

### Security Checklist

- [ ] CSRF protection enabled and enhanced with Sec-Fetch-Site
- [ ] All user input properly escaped in views
- [ ] Parameterized queries for all database operations
- [ ] Sensitive parameters filtered from logs
- [ ] Secure session cookies (httponly, secure, same_site)
- [ ] HTML sanitization configured for rich content
- [ ] Authorization checks on all protected actions
- [ ] Development-only code cannot leak to production

---

## View & Frontend Patterns

### View Organization

Views should be **heavily partitioned** into small, focused partials:

```erb
<!-- app/views/cards/show.html.erb -->
<%= turbo_stream_from @card %>
<%= turbo_stream_from @card, :activity %>

<div data-controller="beacon lightbox">
  <%= render "cards/container", card: @card %>
  <%= render "cards/activity", card: @card unless @card.drafted? %>
</div>
```

**Nested Partials:**

Organize partials by their parent view:

```
app/views/cards/
├── show.html.erb
├── show/
│   ├── _activity.html.erb
│   ├── _meta.html.erb
│   └── _comments.html.erb
├── _container.html.erb
└── container/
    ├── _header.html.erb
    ├── _body.html.erb
    └── _footer.html.erb
```

### Helper Methods

Create **intention-revealing helpers** that encapsulate complex view logic:

```ruby
module CardsHelper
  def card_article_tag(card, id: dom_id(card, :article), data: {}, **options, &block)
    classes = [
      options.delete(:class),
      ("golden-effect" if card.golden?),
      ("card--postponed" if card.postponed?),
      ("card--active" if card.active?)
    ].compact.join(" ")

    data[:drag_and_drop_top] = true if card.golden? && !card.closed?

    tag.article \
      id: id,
      style: "--card-color: #{card.color}; view-transition-name: #{id}",
      class: classes,
      data: data,
      **options,
      &block
  end

  def button_to_delete_card(card)
    button_to card_path(card),
      method: :delete,
      class: "btn txt-negative",
      data: { turbo_frame: "_top", turbo_confirm: "Are you sure?" } do
      concat icon_tag("trash")
      concat tag.span("Delete this card")
    end
  end

  def card_status_badge(card)
    tag.span card.status.humanize,
      class: "badge badge--#{card.status}",
      data: { card_status: card.status }
  end
end
```

### Turbo Patterns

**Turbo Streams for Dynamic Updates:**

```erb
<!-- app/views/cards/update.turbo_stream.erb -->
<%= turbo_stream.replace dom_id(@card, :card_container),
    partial: "cards/container",
    method: :morph,
    locals: { card: @card.reload } %>

<%= turbo_stream.update dom_id(@card, :edit) do %>
  <%= render "cards/container/content_display", card: @card %>
<% end %>
```

**Broadcasting Real-time Updates:**

```erb
<!-- In views, subscribe to updates -->
<%= turbo_stream_from @card %>
<%= turbo_stream_from @card, :activity %>

<!-- In models, broadcast changes -->
class Card < ApplicationRecord
  include Broadcastable

  after_update_commit :broadcast_update

  private
    def broadcast_update
      broadcast_replace_to self,
        target: dom_id(self, :card_container),
        partial: "cards/container",
        locals: { card: self }
    end
end
```

**Turbo Frame Lazy Loading:**

```erb
<turbo-frame id="card_<%= card.id %>_details" src="<%= card_path(card) %>" loading="lazy">
  <p>Loading...</p>
</turbo-frame>
```

### Stimulus Controllers

Write **clean, focused JavaScript controllers**:

```javascript
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dialog" ]
  static values = {
    modal: { type: Boolean, default: false },
    sizing: { type: Boolean, default: true }
  }

  connect() {
    this.dialogTarget.setAttribute("aria-hidden", "true")
  }

  open() {
    if (this.modalValue) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.show()
    }

    this.loadLazyFrames()
    this.dialogTarget.setAttribute("aria-hidden", "false")
    this.dispatch("show")
  }

  close() {
    this.dialogTarget.close()
    this.dispatch("close")
  }

  backdropClick(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  // Private methods use naming convention (no actual private keyword in JS)
  loadLazyFrames() {
    this.dialogTarget
      .querySelectorAll("turbo-frame[loading='lazy']")
      .forEach(frame => { frame.loading = "eager" })
  }
}
```

**Stimulus Conventions:**

- Use `static targets` for DOM element references
- Use `static values` for configuration
- Dispatch custom events for inter-controller communication
- Use data attributes for configuration
- Keep controllers small and focused

**HTML Usage:**

```erb
<div data-controller="dialog">
  <button data-action="click->dialog#open">Open Dialog</button>

  <dialog data-dialog-target="dialog" data-action="click->dialog#backdropClick">
    <h2>Dialog Content</h2>
    <button data-action="click->dialog#close">Close</button>
  </dialog>
</div>
```

### CSS Organization

Use **modern CSS with custom properties**:

```css
/* app/assets/stylesheets/base.css */
@layer base {
  :root {
    --color-canvas: #ffffff;
    --color-ink: #1a1a1a;
    --focus-ring-color: #0066cc;
    --focus-ring-size: 2px;
    --focus-ring-offset: 2px;
  }

  html {
    font-size: 100%;
  }

  body {
    background: var(--color-canvas);
    color: var(--color-ink);
    font-family: var(--font-sans);
  }

  :is(a, button, input) {
    transition: 100ms ease-out;
    transition-property: background-color, border-color, box-shadow;

    &:where(:focus-visible) {
      outline: var(--focus-ring-size) solid var(--focus-ring-color);
      outline-offset: var(--focus-ring-offset);
    }
  }
}
```

**Component CSS:**

```css
/* app/assets/stylesheets/components/card.css */
.card {
  background: white;
  border-radius: 8px;
  border: 1px solid var(--color-border);
  padding: var(--space-4);

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-2);
  }

  &__title {
    font-size: var(--text-lg);
    font-weight: 600;
  }

  &--golden {
    border-color: var(--color-gold);
    box-shadow: 0 0 0 1px var(--color-gold);
  }

  &--postponed {
    opacity: 0.6;
  }
}
```

---

## Helper Patterns

Helpers encapsulate view logic and keep templates clean.

### Tag Builder Helpers

Create semantic, reusable tag builders:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def icon_tag(name, **options)
    tag.span \
      class: class_names("icon icon--#{name}", options.delete(:class)),
      "aria-hidden": true,
      **options
  end

  def inline_svg(name)
    file_path = Rails.root.join("app/assets/images/#{name}.svg")
    return File.read(file_path).html_safe if File.exist?(file_path)
    tag.span "(SVG #{name} not found)", class: "missing-svg"
  end

  def avatar_tag(user, size: :small, **options)
    classes = class_names("avatar avatar--#{size}", options.delete(:class))

    if user.avatar.attached?
      image_tag user.avatar.variant(:small), class: classes, alt: user.name, **options
    else
      tag.span user.initials, class: class_names(classes, "avatar--initials"), **options
    end
  end
end
```

### Auto-linking Helpers

Automatically link URLs and emails in user content:

```ruby
# app/helpers/html_helper.rb
module HtmlHelper
  EMAIL_REGEXP = /\b[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\b/
  URL_REGEXP = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  def format_html(html)
    fragment = Nokogiri::HTML.fragment(html)
    auto_link_urls(fragment)
    auto_link_emails(fragment)
    fragment.to_html.html_safe
  end

  private
    EXCLUDED_ELEMENTS = %w[ a figcaption pre code ]

    def auto_linkable_node?(node)
      node.text? && node.ancestors.none? { |a| EXCLUDED_ELEMENTS.include?(a.name) }
    end

    def auto_link_urls(fragment)
      fragment.traverse do |node|
        next unless auto_linkable_node?(node)
        node.replace node.text.gsub(URL_REGEXP) { |url| link_to url, url, target: "_blank", rel: "noopener" }
      end
    end
end
```

### Stimulus-Aware Form Helpers

Create form helpers that integrate with Stimulus:

```ruby
# app/helpers/forms_helper.rb
module FormsHelper
  def auto_submit_form_with(**attributes, &block)
    data = attributes.delete(:data) || {}
    data[:controller] = "auto-submit #{data[:controller]}".strip
    data[:action] = "change->auto-submit#submit #{data[:action]}".strip

    form_with(**attributes, data: data, &block)
  end

  def dialog_form_with(**attributes, &block)
    data = attributes.delete(:data) || {}
    data[:action] = "turbo:submit-end->dialog#close #{data[:action]}".strip

    form_with(**attributes, data: data, &block)
  end
end
```

### ARIA Attribute Helpers

Manage accessibility attributes consistently:

```ruby
# app/helpers/accessibility_helper.rb
module AccessibilityHelper
  def aria_current(condition, value: "page")
    { "aria-current": value } if condition
  end

  def aria_label(label)
    { "aria-label": label }
  end

  def aria_describedby(*ids)
    { "aria-describedby": ids.join(" ") } if ids.any?
  end

  # Usage in views
  <%= link_to "Home", root_path, **aria_current(current_page?(root_path)) %>
  <%= button_tag "Delete", **aria_label("Delete card") %>
end
```

### Data Attribute Merging

Merge data attributes cleanly:

```ruby
# app/helpers/data_helper.rb
module DataHelper
  def merge_data_attributes(base_data, additional_data)
    base_data.merge(additional_data) do |key, old_val, new_val|
      case key
      when :controller, :action, :class
        [old_val, new_val].join(" ").strip
      else
        new_val
      end
    end
  end

  # Usage
  def card_tag(card, **options)
    base_data = { controller: "drag-and-drop", card_id_value: card.id }
    user_data = options.delete(:data) || {}

    tag.article \
      id: dom_id(card),
      data: merge_data_attributes(base_data, user_data),
      **options
  end
end
```

---

## Turbo & Real-time Updates

### Broadcast Suppression

Prevent unnecessary broadcasts during processing:

```ruby
# app/models/concerns/card/broadcastable.rb
module Card::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes

    before_update :remember_if_preview_changed
  end

  private
    def remember_if_preview_changed
      @preview_changed = title_changed? || column_id_changed? || board_id_changed?
    end

    def broadcast_preview_update
      return unless @preview_changed

      broadcast_replace_to \
        self,
        target: dom_id(self, :preview),
        partial: "cards/preview",
        locals: { card: self }
    end
end

# Suppress broadcasts during bulk operations
Card.suppressing_turbo_broadcasts do
  cards.each { |card| card.update!(status: :archived) }
end
```

### Conditional Broadcasting

Only broadcast what changed:

```ruby
# app/models/card.rb
class Card < ApplicationRecord
  after_update_commit :broadcast_changes

  private
    def broadcast_changes
      broadcast_title_update if saved_change_to_title?
      broadcast_status_update if saved_change_to_status?
      broadcast_move if saved_change_to_column_id?
    end

    def broadcast_title_update
      broadcast_replace_to self, :title,
        target: dom_id(self, :title),
        partial: "cards/title",
        locals: { card: self }
    end

    def broadcast_move
      # Remove from old column
      broadcast_remove_to [board, previous_column], :cards,
        target: dom_id(self)

      # Add to new column
      broadcast_prepend_to [board, column], :cards,
        target: dom_id(column, :cards),
        partial: "cards/card",
        locals: { card: self }
    end
end
```

### Morphing vs Replacing

Use morphing for smooth updates:

```erb
<!-- Morph preserves focus and form state -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    method: :morph,
    locals: { card: @card } %>

<!-- Replace for complete re-render -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    locals: { card: @card } %>
```

### Multi-Channel Broadcasting

Subscribe to multiple streams:

```erb
<!-- Subscribe to card-specific updates -->
<%= turbo_stream_from @card %>

<!-- Subscribe to card activity updates -->
<%= turbo_stream_from @card, :activity %>

<!-- Subscribe to board updates -->
<%= turbo_stream_from @board %>
```

---

## Stimulus Advanced Patterns

### Private Fields

Use `#` prefix for private fields:

```javascript
// app/javascript/controllers/auto_save_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #timer
  #delay = 1000

  connect() {
    this.element.addEventListener("input", () => this.#scheduleSave())
  }

  disconnect() {
    this.#cancelTimer()
    this.#save()
  }

  #scheduleSave() {
    this.#cancelTimer()
    this.#timer = setTimeout(() => this.#save(), this.#delay)
  }

  #cancelTimer() {
    if (this.#timer) {
      clearTimeout(this.#timer)
      this.#timer = null
    }
  }

  async #save() {
    this.#cancelTimer()
    const form = this.element.closest("form")
    await fetch(form.action, {
      method: form.method,
      body: new FormData(form)
    })
  }
}
```

### Async/Await Patterns

Handle asynchronous operations cleanly:

```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "results" ]
  static values = { url: String }

  #abortController

  async search() {
    const query = this.inputTarget.value

    if (query.length < 3) {
      this.clearResults()
      return
    }

    this.#abortPreviousRequest()
    this.showLoading()

    try {
      const results = await this.#fetchResults(query)
      this.displayResults(results)
    } catch (error) {
      if (error.name !== "AbortError") {
        this.handleError(error)
      }
    }
  }

  #abortPreviousRequest() {
    this.#abortController?.abort()
    this.#abortController = new AbortController()
  }

  async #fetchResults(query) {
    const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
    const response = await fetch(url, {
      signal: this.#abortController.signal
    })
    return response.json()
  }
}
```

### Custom Event Dispatching

Communicate between controllers:

```javascript
// app/javascript/controllers/dialog_controller.js
export default class extends Controller {
  open(event) {
    this.dialogTarget.showModal()
    this.dispatch("opened", { detail: { element: this.element } })
  }

  close() {
    this.dialogTarget.close()
    this.dispatch("closed")
  }
}

// Listening in another controller
export default class extends Controller {
  connect() {
    this.element.addEventListener("dialog:opened", this.#handleDialogOpened)
  }

  #handleDialogOpened = (event) => {
    console.log("Dialog opened:", event.detail.element)
  }
}
```

---

## CSS Architecture

### Modern CSS Layers

Organize styles using cascade layers:

```css
/* app/assets/stylesheets/application.css */
@layer base, components, utilities;

/* app/assets/stylesheets/base.css */
@layer base {
  :root {
    /* Colors */
    --color-canvas: #ffffff;
    --color-ink: #1a1a1a;
    --color-border: #e5e7eb;

    /* Spacing */
    --space-1: 0.25rem;
    --space-2: 0.5rem;
    --space-4: 1rem;

    /* Typography */
    --font-sans: system-ui, sans-serif;
    --text-sm: 0.875rem;
    --text-base: 1rem;
    --text-lg: 1.125rem;
  }

  *,
  *::before,
  *::after {
    box-sizing: border-box;
  }

  body {
    font-family: var(--font-sans);
    color: var(--color-ink);
    background: var(--color-canvas);
  }
}
```

### Logical Properties

Use logical properties for internationalization:

```css
/* app/assets/stylesheets/components/card.css */
.card {
  padding-block: var(--space-4);
  padding-inline: var(--space-6);
  margin-block-end: var(--space-4);
  border-inline-start: 3px solid var(--card-color);
}

.card__title {
  margin-block-end: var(--space-2);
}

.card__actions {
  margin-inline-start: auto;
}
```

### Focus-Visible Pattern

Modern focus management:

```css
@layer base {
  :is(a, button, input, textarea, select) {
    transition: 100ms ease-out;
    transition-property: background-color, border-color, box-shadow;

    /* Only show focus ring for keyboard navigation */
    &:where(:focus-visible) {
      outline: var(--focus-ring-size, 2px) solid var(--focus-ring-color);
      outline-offset: var(--focus-ring-offset, 2px);
    }

    /* Hide default focus outline */
    &:focus:not(:focus-visible) {
      outline: none;
    }
  }
}
```

### Utility Classes with Logical Properties

```css
@layer utilities {
  /* Logical padding */
  .pad-block { padding-block: var(--block-space, 1rem); }
  .pad-inline { padding-inline: var(--inline-space, 1rem); }

  /* Logical margins */
  .m-block-start { margin-block-start: var(--space-4); }
  .m-block-end { margin-block-end: var(--space-4); }

  /* Flexbox utilities */
  .flex { display: flex; }
  .flex-col { flex-direction: column; }
  .items-center { align-items: center; }
  .justify-between { justify-content: space-between; }
  .gap { gap: var(--gap-size, 1rem); }

  /* Accessibility */
  .visually-hidden {
    block-size: 1px;
    inline-size: 1px;
    clip-path: inset(50%);
    overflow: hidden;
    position: absolute;
    white-space: nowrap;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border-width: 0;
  }
}
```

---

## Rails Extensions & Monkey Patching

### Organization Pattern

Keep all Rails extensions in `lib/rails_ext/`:

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

Use `prepend` to override existing methods:

```ruby
# lib/rails_ext/active_storage_suppress_broadcasts.rb
module ActiveStorageAnalyzeJobSuppressBroadcasts
  def perform(blob)
    # Prevent page refreshes during blob analysis
    Board.suppressing_turbo_broadcasts do
      Card.suppressing_turbo_broadcasts do
        super
      end
    end
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::AnalyzeJob.prepend(ActiveStorageAnalyzeJobSuppressBroadcasts)
end
```

### Core Class Extensions

Keep core extensions minimal and well-documented:

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

### One-Click Unsubscribe Headers

Implement RFC 8058 compliant unsubscribe:

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
end
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

  def remote_images
    description&.body&.attachables&.grep(ActionText::Attachables::RemoteImage) || []
  end

  def embedded_videos
    description&.body&.attachables&.select { |a| a.is_a?(ActionText::Attachables::ContentAttachment) && a.attachable_type == "Video" }
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

  # Reactive setter - updates user when account changes
  def session=(value)
    super(value)
    if value.present? && account.present?
      self.user = identity.users.find_by(account: account)
    end
  end

  # Context switching helpers
  def with_account(value, &block)
    with(account: value, &block)
  end

  def without_account(&block)
    with(account: nil, &block)
  end

  # Batch context switching
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
    after_action :clear_current_request_context
  end

  private
    def set_current_request_context
      Current.http_method = request.method
      Current.request_id = request.uuid
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
      Current.referrer = request.referrer
    end

    def clear_current_request_context
      # Context is automatically cleared after the request
      # This is just for explicit documentation
    end
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

### Scope Module vs Namespace

```ruby
# config/routes.rb

# Use scope module: to avoid nesting URLs but organize controllers
resources :boards do
  scope module: :boards do
    resource :publication    # /boards/:board_id/publication
    resource :entropy        # /boards/:board_id/entropy
    resources :columns       # /boards/:board_id/columns
  end
end

# Use namespace for both URL and controller organization
namespace :admin do
  resources :accounts        # /admin/accounts → Admin::AccountsController
  resources :users           # /admin/users → Admin::UsersController
end

# Nested namespace for complex organization
namespace :api do
  namespace :v1 do
    resources :cards         # /api/v1/cards → Api::V1::CardsController
  end
end
```

### Singular Resources

Use singular resources for one-per-parent resources:

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

For complex nested resources, organize clearly:

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
              resource :column
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

### Zero-Downtime Migration Strategy

```ruby
# Strong migrations config
# config/initializers/strong_migrations.rb
StrongMigrations.start_after = 20240101000000

StrongMigrations.auto_analyze = true
StrongMigrations.target_version = 8.0

StrongMigrations.check_down = true
```

---

## Testing Patterns

### Test Structure

```ruby
require "test_helper"

class CardTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "create assigns a number to the card" do
    user = users(:david)
    board = boards(:writebook)
    account = board.account

    assert_difference -> { account.reload.cards_count }, +1 do
      card = Card.create!(title: "Test", board: board, creator: user)
      assert_equal account.cards_count, card.number
    end
  end

  test "assignment toggling" do
    card = cards(:logo)
    user = users(:kevin)

    assert card.assigned_to?(user)

    assert_difference({
      -> { card.assignees.count } => -1,
      -> { Event.count } => +1
    }) do
      card.toggle_assignment user
    end

    assert_not card.reload.assigned_to?(user)
  end

  test "moving card between boards updates associations" do
    card = cards(:logo)
    new_board = boards(:campfire)

    card.move_to(new_board)

    assert_equal new_board, card.reload.board
    assert_equal new_board.id, card.events.last.board_id
  end
end
```

### Controller Tests

```ruby
require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create" do
    assert_difference -> { Board.count }, +1 do
      post boards_path, params: { board: { name: "Remodel Punch List" } }
    end

    board = Board.last
    assert_redirected_to board_path(board)
    assert_includes board.users, users(:kevin)
    assert_equal "Remodel Punch List", board.name
  end

  test "update" do
    board = boards(:writebook)

    patch board_path(board), params: {
      board: { name: "Updated Name", all_access: false }
    }

    assert_redirected_to edit_board_path(board)
    assert_equal "Updated Name", board.reload.name
  end

  test "cannot access other account's boards" do
    other_board = boards(:other_account_board)

    assert_raises ActiveRecord::RecordNotFound do
      get board_path(other_board)
    end
  end
end
```

### System Tests

Use system tests for **full integration testing**:

```ruby
require "application_system_test_case"

class CardFlowTest < ApplicationSystemTestCase
  test "create and edit a card" do
    sign_in_as users(:david)

    visit board_url(boards(:writebook))
    click_on "Add a card"

    fill_in "card_title", with: "Fix the homepage"
    fill_in_lexxy with: "The hero section needs updating"
    click_on "Create card"

    assert_selector "h3", text: "Fix the homepage"
    assert_text "The hero section needs updating"

    # Edit the card
    click_on "Edit"
    fill_in "card_title", with: "Update the homepage"
    click_on "Save"

    assert_selector "h3", text: "Update the homepage"
  end

  test "dragging card to a new column" do
    sign_in_as users(:david)
    card = cards(:logo)
    target_column = columns(:in_progress)

    visit board_url(boards(:writebook))

    card_el = find("#article_card_#{card.id}")
    column_el = find("#column_#{target_column.id}")

    card_el.drag_to(column_el)

    assert_equal target_column, card.reload.column
  end
end
```

### Fixture Patterns

Use **ERB in fixtures** for dynamic data:

```yaml
# test/fixtures/cards.yml
logo:
  id: <%= ActiveRecord::FixtureSet.identify("logo", :uuid) %>
  number: 1
  board: writebook
  creator: david
  title: The logo isn't big enough
  created_at: <%= 1.week.ago %>
  status: published
  account: 37s

feature_request:
  id: <%= ActiveRecord::FixtureSet.identify("feature_request", :uuid) %>
  number: 2
  board: writebook
  creator: kevin
  title: Add dark mode
  created_at: <%= 3.days.ago %>
  status: active
  account: 37s
```

### Test Helpers

Create helpers for common test operations:

```ruby
# test/test_helper.rb
module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    include ActiveJob::TestHelper
    include ActionTextTestHelper

    setup do
      Current.account = accounts(:37s)
    end

    teardown do
      Current.clear_all
    end
  end
end

# test/support/card_test_helper.rb
module CardTestHelper
  def create_card(**attributes)
    defaults = {
      board: boards(:writebook),
      creator: users(:david),
      title: "Test Card"
    }
    Card.create!(defaults.merge(attributes))
  end
end
```

### Multi-Tenant Test Helpers

Test multi-tenant features with context switching:

```ruby
# test/support/session_test_helper.rb
module SessionTestHelper
  def sign_in_as(identity_or_name)
    identity = identity_or_name.is_a?(Identity) ? identity_or_name : identities(identity_or_name)
    identity.send_magic_link
    magic_link = identity.magic_links.order(id: :desc).first

    untenanted do
      post session_magic_link_url, params: { code: magic_link.code }
    end

    assert_response :redirect
  end

  def untenanted(&block)
    original_script_name = integration_session.default_url_options[:script_name]
    integration_session.default_url_options[:script_name] = ""
    yield
  ensure
    integration_session.default_url_options[:script_name] = original_script_name
  end
end
```

### VCR Configuration for API Testing

Mock external HTTP requests in tests:

```ruby
# test/test_helper.rb
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = { record: :new_episodes }

  # Filter sensitive data
  config.filter_sensitive_data("<OPENAI_API_KEY>") do
    Rails.application.credentials.openai_api_key
  end

  config.filter_sensitive_data("<STRIPE_SECRET_KEY>") do
    Rails.application.credentials.dig(:stripe, :secret_key)
  end

  # Custom matcher to ignore timestamps
  config.register_request_matcher :body_without_times do |r1, r2|
    b1 = (r1.body || "").gsub(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} UTC/, "<TIME>")
    b2 = (r2.body || "").gsub(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} UTC/, "<TIME>")
    b1 == b2
  end
end

# Usage in tests
test "fetches AI suggestions" do
  VCR.use_cassette("openai/suggestions") do
    suggestions = AiService.generate_suggestions("Fix homepage")
    assert_includes suggestions, "Update hero section"
  end
end
```

### Deterministic UUID Fixtures

Generate deterministic UUIDs for fixtures that sort correctly:

```ruby
# test/fixtures_helper.rb
module FixturesHelper
  def self.generate_uuid(label)
    require "zlib"

    # Create deterministic but unique ID based on label
    fixture_int = Zlib.crc32("fixtures/#{label}") % (2**30 - 1)

    # Base time ensures fixtures are "older" than runtime records
    base_time = Time.utc(2024, 1, 1, 0, 0, 0)
    timestamp = base_time + (fixture_int / 1000.0)

    # Generate UUIDv7 with deterministic timestamp
    uuid_v7_with_timestamp(timestamp, label)
  end

  def self.uuid_v7_with_timestamp(timestamp, label)
    # Implementation of UUIDv7 generation
    # ... (simplified for brevity)
  end
end

# In fixtures
# test/fixtures/cards.yml
logo:
  id: <%= FixturesHelper.generate_uuid("card_logo") %>
  # ... rest of fixture
```

---

## Database & Query Patterns

### Migration Style

Keep migrations **minimal and focused**:

```ruby
class AddNumberToCards < ActiveRecord::Migration[8.2]
  def change
    add_column :cards, :number, :bigint, null: false
    add_column :accounts, :cards_count, :bigint, default: 0, null: false
    add_index :cards, [:account_id, :number], unique: true
  end
end
```

**Migration Best Practices:**

- Use `null: false` with sensible defaults
- Add indexes for foreign keys and commonly queried columns
- Use `change` method when possible (reversible)
- Keep data migrations separate from schema migrations

### Schema Conventions

```ruby
create_table :cards, id: :uuid do |t|
  t.uuid :account_id, null: false          # Tenant isolation
  t.uuid :board_id, null: false
  t.uuid :creator_id, null: false
  t.bigint :number, null: false            # Sequential within account

  t.string :title, null: false
  t.string :status, default: "active", null: false
  t.datetime :last_active_at

  t.timestamps                             # created_at, updated_at

  t.index [:account_id, :number], unique: true
  t.index :board_id
  t.index :creator_id
  t.index [:status, :last_active_at]       # Composite for common queries
end
```

**Conventions:**

- UUIDs for primary keys (better for distributed systems)
- `account_id` on every table for multi-tenancy
- `null: false` for required fields
- Timestamps on all tables
- Composite indexes for common query patterns

### Query Optimization

**Preloading Associations:**

```ruby
# Define preload scopes in models
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
cards = Card.active.preloaded
```

**Complex Queries with SQL:**

```ruby
scope :due_to_be_postponed, -> do
  active
    .joins(board: :account)
    .left_outer_joins(board: :entropy)
    .where(
      "cards.last_active_at <= ?",
      Time.now - POSTPONE_PERIOD
    )
end
```

**Use `find_each` for Batch Processing:**

```ruby
# GOOD - Processes in batches
Card.active.find_each do |card|
  card.update_search_index
end

# BAD - Loads all records into memory
Card.active.each do |card|
  card.update_search_index
end
```

---

## Background Jobs

### Job Pattern

Jobs should be **thin wrappers** that delegate to domain models:

```ruby
# Model concern handles the logic
module Event::Relaying
  extend ActiveSupport::Concern

  included do
    after_create_commit :relay_later
  end

  def relay_later
    Event::RelayJob.perform_later(self)
  end

  def relay_now
    webhooks.each do |webhook|
      webhook.deliver(event: self)
    end
  end
end

# Job is just a wrapper
class Event::RelayJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.relay_now
  end
end
```

### Job Organization

Organize jobs by **domain namespace**:

```
app/jobs/
├── application_job.rb
├── card/
│   ├── auto_postpone_job.rb
│   └── notify_watchers_job.rb
├── event/
│   └── relay_job.rb
└── notification/
    └── deliver_job.rb
```

### Naming Conventions

- **`_later` suffix**: Methods that enqueue jobs asynchronously
- **`_now` suffix**: Synchronous versions of the same operation

```ruby
class Card < ApplicationRecord
  def notify_watchers_later
    Card::NotifyWatchersJob.perform_later(self)
  end

  def notify_watchers_now
    watchers.each do |user|
      Notification.create!(user: user, source: self)
    end
  end
end
```

### Recurring Jobs

Use `config/recurring.yml` for scheduled tasks:

```yaml
# config/recurring.yml
deliver_bundled_notifications:
  class: Notification::DeliverJob
  schedule: "*/30 * * * *"  # Every 30 minutes

auto_postpone_stale_cards:
  class: Card::AutoPostponeJob
  schedule: "0 * * * *"     # Every hour
```

### Multi-Tenant Context in Jobs

Automatically preserve and restore account context:

```ruby
# config/initializers/active_job.rb
module FizzyActiveJobExtensions
  extend ActiveSupport::Concern

  prepended do
    attr_reader :account
    self.enqueue_after_transaction_commit = true
  end

  # Capture current account when job is created
  def initialize(...)
    super
    @account = Current.account
  end

  # Serialize account to job payload
  def serialize
    super.merge("account" => @account&.to_gid)
  end

  # Deserialize account from job payload
  def deserialize(job_data)
    super
    if account_gid = job_data["account"]
      @account = GlobalID::Locator.locate(account_gid)
    end
  end

  # Restore account context when performing job
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

This ensures jobs always run in the correct tenant context, even when delayed or queued.

---

## Form Objects & POROs

### When to Use Form Objects

Form objects are useful when:
- Form spans multiple models
- Complex validation logic that doesn't belong in a model
- Non-database-backed forms (search, filters, contact forms)
- Business process with multiple steps

**DON'T use form objects when:**
- Simple CRUD operations (use models directly)
- Single model with standard validations

### Form Object Pattern

```ruby
# app/models/signup.rb
class Signup
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :full_name, :string
  attribute :email_address, :string
  attr_reader :account, :user, :identity

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Context-specific validations
  with_options on: :completion do
    validates_presence_of :full_name, :identity
  end

  def complete
    return false unless valid?(:completion)

    begin
      create_account_and_user
      true
    rescue => error
      cleanup_on_failure
      handle_error(error)
      false
    end
  end

  private
    def create_account_and_user
      Account.transaction do
        @account = Account.create!(name: account_name)
        @user = @account.users.create!(
          identity: identity,
          name: full_name,
          role: :owner
        )
      end
    end

    def cleanup_on_failure
      @account&.destroy
    end

    def handle_error(error)
      errors.add(:base, "Something went wrong. Please try again.")
      Rails.error.report(error, severity: :error)
    end
end

# In controller
class SignupsController < ApplicationController
  def create
    @signup = Signup.new(signup_params)

    if @signup.complete
      redirect_to dashboard_path(@signup.account)
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

### Context-Specific Validations

Use `on:` option for multi-step forms:

```ruby
class Subscription
  include ActiveModel::Model

  attribute :email, :string
  attribute :plan, :string
  attribute :payment_method, :string

  # Step 1: Email validation
  validates :email, presence: true, on: :email_step

  # Step 2: Plan validation
  validates :plan, presence: true, inclusion: { in: %w[basic pro enterprise] }, on: :plan_step

  # Step 3: Payment validation
  validates :payment_method, presence: true, on: :payment_step

  # Final validation
  validates :email, :plan, :payment_method, presence: true, on: :completion

  def complete_step(step)
    valid?(step)
  end
end
```

### Query Objects

Encapsulate complex queries in POROs:

```ruby
# app/queries/card_search.rb
class CardSearch
  attr_reader :relation

  def initialize(relation = Card.all)
    @relation = relation.extending(Scopes)
  end

  def search(params)
    @relation = relation.all
    filter_by_status(params[:status])
    filter_by_tags(params[:tag_ids])
    filter_by_assignee(params[:assignee_id])
    search_text(params[:query])
    sort_by(params[:sort])
    @relation
  end

  private
    def filter_by_status(status)
      @relation = relation.indexed_by(status) if status.present?
    end

    def filter_by_tags(tag_ids)
      @relation = relation.tagged_with(tag_ids) if tag_ids.present?
    end

    def search_text(query)
      @relation = relation.search(query) if query.present?
    end

  module Scopes
    def recent_first
      order(created_at: :desc)
    end
  end
end

# Usage
cards = CardSearch.new(Current.user.accessible_cards).search(params)
```

### Service Objects (Use Sparingly)

Only when operation is truly complex and doesn't fit in a model:

```ruby
# app/services/board_duplicator.rb
class BoardDuplicator
  def initialize(board, account:)
    @board = board
    @account = account
  end

  def duplicate
    new_board = nil

    Board.transaction do
      new_board = create_board_copy
      duplicate_columns(new_board)
      duplicate_cards(new_board)
      duplicate_accesses(new_board)
    end

    new_board
  end

  private
    def create_board_copy
      @account.boards.create!(
        name: "#{@board.name} (Copy)",
        all_access: @board.all_access
      )
    end

    def duplicate_columns(new_board)
      @board.columns.each do |column|
        new_board.columns.create!(
          name: column.name,
          position: column.position
        )
      end
    end

    # ... more private methods
end

# Usage - clear, explicit call
duplicator = BoardDuplicator.new(board, account: Current.account)
new_board = duplicator.duplicate
```

**Prefer rich models over service objects:**

```ruby
# ❌ Overuse of service objects
AccountCreator.new(params).create
CardCloser.new(card, user).close

# ✅ Rich model methods
Account.create_with_defaults(params)
card.close(user: user)
```

---

## Code Style & Conventions

### Conditional Returns

Prefer **expanded conditionals** over guard clauses:

```ruby
# ❌ BAD - Early return makes flow harder to follow
def todos_for_new_group
  ids = params.require(:todolist)[:todo_ids]
  return [] unless ids
  @bucket.recordings.todos.find(ids.split(","))
end

# ✅ GOOD - Clear if/else structure
def todos_for_new_group
  if ids = params.require(:todolist)[:todo_ids]
    @bucket.recordings.todos.find(ids.split(","))
  else
    []
  end
end
```

**Exception:** Guard clauses allowed at method start for **non-trivial methods**:

```ruby
# ✅ ACCEPTABLE - Guard clause at method start
def after_recorded_as_commit(recording)
  return if recording.parent.was_created?

  if recording.was_created?
    broadcast_new_column(recording)
  else
    broadcast_column_change(recording)
  end
end
```

### Method Ordering

**Order methods by invocation flow**, not alphabetically:

```ruby
class CardProcessor
  def process
    validate_card
    enrich_card
    save_card
  end

  private
    def validate_card
      check_title
      check_description
    end

    def check_title
      # ...
    end

    def check_description
      # ...
    end

    def enrich_card
      # ...
    end

    def save_card
      # ...
    end
end
```

**Overall method order:**

1. `class` methods
2. `public` methods (with `initialize` at top if present)
3. `private` methods

### Visibility Modifiers

**No newline under visibility modifiers**, indent content:

```ruby
class SomeClass
  def public_method
    # ...
  end

  private
    def private_method_1
      # ...
    end

    def private_method_2
      # ...
    end
end
```

For modules with **only private methods**:

```ruby
module SomeModule
  private

  def some_private_method
    # ...
  end

  def another_private_method
    # ...
  end
end
```

### Bang Methods (!)

Only use `!` for methods with **non-bang counterparts**. Don't use to flag destructive actions:

```ruby
# ✅ GOOD - Has a non-bang version
user.save   # Returns boolean
user.save!  # Raises exception

card.update(title: "New")   # Returns boolean
card.update!(title: "New")  # Raises exception

# ❌ BAD - No non-bang version
card.destroy!  # Just use destroy
```

### Method Length

Keep methods **short and focused** (generally under 10 lines):

```ruby
# ✅ GOOD - Short, focused methods
def close(user:)
  update_status_to_closed
  track_closure_event(user)
  notify_watchers
end

# ❌ BAD - Too long, doing too much
def close(user:)
  self.status = :closed
  self.closed_at = Time.current
  self.closed_by = user
  save!

  Event.create!(
    action: "card_closed",
    creator: user,
    eventable: self
  )

  watchers.each do |watcher|
    Notification.create!(
      user: watcher,
      source: self,
      action: "closed"
    )
  end
end
```

### Naming Conventions

**Be explicit and intention-revealing:**

```ruby
# ✅ GOOD - Clear intent
def accessible_to?(user)
  all_access? || accesses.exists?(user: user)
end

def postponed?
  status == "not_now"
end

def auto_postpone(user:)
  postpone(user: user, reason: :entropy)
end

# ❌ BAD - Unclear naming
def check(u)
  aa? || a.exists?(user: u)
end

def pp?
  s == "not_now"
end
```

**Boolean Methods:**

- Use `?` suffix for predicates: `active?`, `closed?`, `accessible_to?`
- Use `is_` or `has_` prefix sparingly, prefer direct adjectives

**Collection Methods:**

- Plural for collections: `cards`, `users`, `boards`
- Singular for single items: `card`, `user`, `board`

---

## Quick Reference

### Model Checklist

- [ ] Concerns listed alphabetically
- [ ] Associations before validations
- [ ] Validations before callbacks
- [ ] Callbacks ordered by lifecycle
- [ ] Scopes after callbacks
- [ ] Public methods before private
- [ ] Methods ordered by invocation flow

### Controller Checklist

- [ ] Use RESTful resources (no custom actions)
- [ ] Keep controllers thin (delegate to models)
- [ ] Use `params.expect` for strong parameters
- [ ] Extract common setup into concerns
- [ ] Authorization checks explicit and simple

### View Checklist

- [ ] Partition into small, focused partials
- [ ] Use helpers for complex logic
- [ ] Turbo Streams for dynamic updates
- [ ] Stimulus controllers small and focused
- [ ] Modern CSS with custom properties

### Testing Checklist

- [ ] Test all public methods
- [ ] Use fixtures for test data
- [ ] System tests for critical flows
- [ ] Test helpers for common operations
- [ ] Assert behavior, not implementation

### Job Checklist

- [ ] Jobs are thin wrappers
- [ ] Logic lives in models
- [ ] Use `_later` / `_now` suffix convention
- [ ] Namespace by domain
- [ ] Handle failures gracefully

---

## Additional Resources

- **Official Rails Guides**: https://guides.rubyonrails.org/
- **Rubocop Rails Omakase**: https://github.com/rails/rubocop-rails-omakase
- **Turbo Handbook**: https://turbo.hotwired.dev/handbook/introduction
- **Stimulus Handbook**: https://stimulus.hotwired.dev/handbook/introduction

---

## Conclusion

These standards represent years of Rails experience distilled into practical, proven patterns. The key is **consistency** - pick these patterns and apply them uniformly across your codebase.

Remember:

1. **Vanilla Rails first** - Don't over-architect
2. **Rich models, thin controllers** - Domain logic in models
3. **RESTful resources** - No custom actions
4. **Test everything** - Comprehensive coverage
5. **Be explicit** - Clear beats clever

Happy coding! 🚀
