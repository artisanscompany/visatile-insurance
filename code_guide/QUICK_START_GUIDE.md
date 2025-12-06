# Rails Quick-Start Guide: Top 20 Essential Patterns

> **Get productive fast** - The most important patterns from the 37signals Fizzy codebase

---

## 1. Model Structure (Always Follow This Order)

```ruby
class Card < ApplicationRecord
  # 1. Concerns (alphabetically)
  include Assignable, Closeable, Eventable

  # 2. Associations
  belongs_to :board
  has_many :comments, dependent: :destroy

  # 3. Validations
  validates :title, presence: true

  # 4. Callbacks
  before_create :assign_number
  after_update :broadcast_changes

  # 5. Scopes
  scope :active, -> { where(status: :active) }

  # 6. Public methods
  def close(user:)
    update!(status: :closed)
    track_event(:closed, creator: user)
  end

  # 7. Private methods
  private
    def assign_number
      self.number = account.increment!(:cards_count).cards_count
    end
end
```

## 2. RESTful Controllers (Never Add Custom Actions)

```ruby
# ❌ BAD
resources :cards do
  post :close
  post :assign
end

# ✅ GOOD - Create new resources instead
resources :cards do
  resource :closure      # POST to create, DELETE to destroy
  resource :assignment
end
```

## 3. Thin Controllers, Rich Models

```ruby
# ✅ Controller just coordinates
class Cards::ClosuresController < ApplicationController
  def create
    @card.close(user: Current.user)  # Logic in model
    render_card_replacement
  end
end

# ✅ Model contains business logic
class Card < ApplicationRecord
  def close(user:)
    update!(status: :closed, closed_at: Time.current)
    track_event(:closed, creator: user)
    notify_watchers
  end
end
```

## 4. Use Concerns for Composition

```ruby
# app/models/card/eventable.rb
module Card::Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable
  end

  def track_event(action, creator:, **particulars)
    events.create!(
      action: "card_#{action}",
      creator: creator,
      particulars: particulars
    )
  end
end
```

## 5. Strong Parameters (Rails 8)

```ruby
def card_params
  params.expect(card: [ :title, :description, :status, tag_ids: [] ])
end
```

## 6. Security: Always Parameterize Queries

```ruby
# ✅ GOOD
Card.where("title LIKE ?", "%#{term}%")
Card.where(status: params[:status])

# ❌ BAD - SQL injection!
Card.where("title LIKE '%#{params[:term]}%'")
```

## 7. Security: Escape User Content

```ruby
<!-- ✅ GOOD - Auto-escaped -->
<%= @card.title %>

<!-- ❌ BAD - XSS vulnerability -->
<%= raw @user_input %>
```

## 8. Security: Secure Session Cookies

```ruby
cookies.signed.permanent[:session_token] = {
  value: session.signed_id,
  httponly: true,
  secure: Rails.env.production?,
  same_site: :lax
}
```

## 9. Multi-Tenancy with Current Attributes

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account

  def session=(value)
    super(value)
    if value.present? && account.present?
      self.user = identity.users.find_by(account: account)
    end
  end
end

# Every model has account_id
class Card < ApplicationRecord
  belongs_to :account
end
```

## 10. Turbo Streams for Dynamic Updates

```erb
<!-- Subscribe to updates -->
<%= turbo_stream_from @card %>

<!-- Update the card -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    method: :morph,
    locals: { card: @card } %>
```

## 11. Stimulus Controllers (Keep Simple)

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dialog" ]

  open() {
    this.dialogTarget.showModal()
    this.dispatch("opened")
  }

  close() {
    this.dialogTarget.close()
  }
}
```

## 12. Modern CSS with Custom Properties

```css
@layer base {
  :root {
    --color-primary: #0066cc;
    --space-4: 1rem;
  }

  body {
    color: var(--color-ink);
  }

  button:focus-visible {
    outline: 2px solid var(--color-primary);
  }
}
```

## 13. Helper Methods for Complex View Logic

```ruby
def card_article_tag(card, **options)
  classes = class_names(
    "card",
    ("card--golden" if card.golden?),
    options.delete(:class)
  )

  tag.article id: dom_id(card), class: classes, **options
end
```

## 14. Partition Views into Small Partials

```
app/views/cards/
├── show.html.erb          # Main view
├── show/
│   ├── _header.html.erb   # Focused partials
│   ├── _content.html.erb
│   └── _comments.html.erb
```

## 15. Background Jobs: Thin Wrappers

```ruby
# Model has the logic
module Event::Relaying
  def relay_later
    Event::RelayJob.perform_later(self)
  end

  def relay_now
    webhooks.each { |wh| wh.deliver(event: self) }
  end
end

# Job just delegates
class Event::RelayJob < ApplicationJob
  def perform(event)
    event.relay_now
  end
end
```

## 16. Use Scopes for Chainable Queries

```ruby
class Card < ApplicationRecord
  scope :active, -> { where(status: :active) }
  scope :recent, -> { where("created_at >= ?", 30.days.ago) }
  scope :tagged_with, ->(tag_ids) { joins(:taggings).where(taggings: { tag_id: tag_ids }) }
end

# Chain them together
Card.active.recent.tagged_with([1, 2, 3])
```

## 17. Avoid N+1 Queries with Preloading

```ruby
# Define preload scopes
scope :preloaded, -> do
  preload(:creator, :tags, board: :columns)
    .with_rich_text_description_and_embeds
end

# Use in controllers
@cards = Card.active.preloaded
```

## 18. Method Ordering (Top to Bottom Flow)

```ruby
class CardProcessor
  def process
    validate
    transform
    save
  end

  private
    def validate
      check_title
      check_status
    end

    def check_title
      # ...
    end

    def check_status
      # ...
    end

    def transform
      # ...
    end

    def save
      # ...
    end
end
```

## 19. Form Objects for Complex Forms

```ruby
class Signup
  include ActiveModel::Model

  attribute :email, :string
  attribute :full_name, :string

  validates :email, presence: true

  def complete
    return false unless valid?

    Account.transaction do
      create_account
      create_user
    end
  end
end
```

## 20. Testing: Setup, Action, Assert

```ruby
test "closing card creates event" do
  card = cards(:logo)
  user = users(:david)

  assert_difference -> { Event.count }, +1 do
    card.close(user: user)
  end

  assert card.reload.closed?
  assert_equal "card_closed", Event.last.action
end
```

---

## Quick Reference Card

**Models:** Concerns → Associations → Validations → Callbacks → Scopes → Methods
**Controllers:** Thin coordinators, RESTful resources only
**Security:** Parameterize queries, escape output, secure cookies
**Views:** Small partials, helpers for logic, Turbo for updates
**Testing:** Test behavior, use fixtures, preload data
**Jobs:** Thin wrappers, logic in models, use `_later`/`_now`
**Performance:** Preload associations, use scopes, avoid N+1

---

## What's Next?

1. Read the full [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) for complete patterns
2. Follow the [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md) for structured learning
3. Reference domain guides:
   - [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) for models, controllers, security
   - [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md) for views, Turbo, Stimulus
   - [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md) for deployment, config

## Remember

✅ **Vanilla Rails first** - Don't over-engineer
✅ **Rich models, thin controllers** - Business logic in models
✅ **RESTful resources** - No custom controller actions
✅ **Security by default** - Parameterize, escape, validate
✅ **Test everything** - Behavior over implementation
