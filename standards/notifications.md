# Notifications

> Time window bundling, user preferences, and real-time updates.

---

## Read State Management with Timestamps

**Pattern**: Use `read_at` timestamps instead of boolean `read` flags.

**Why it matters**: Timestamps provide both state AND temporal information, enabling time-based queries and analytics without additional columns.

```ruby
# From PR [#208](https://github.com/basecamp/fizzy/pull/208)
class Notification < ApplicationRecord
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :ordered, -> { order(read_at: :desc, created_at: :desc) }

  def read?
    read_at.present?
  end

  def self.read_all
    update!(read_at: Time.current)
  end

  def read
    update!(read_at: Time.current)
  end
end
```

**Benefits**:
- Know WHEN something was read, not just IF it was read
- Enables "show me notifications read in the last week" type queries
- Supports features like "mark as unread" (just nil out the timestamp)
- Trivial to upgrade from boolean (add timestamp, backfill with `created_at` for read items)

---

## 2. Notification Bundling with Time Windows

**Pattern**: Bundle notifications into time windows rather than linking individual notifications to bundles.

**Why it matters**: Lightweight, immutable design that avoids complex many-to-many relationships.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
class Notification::Bundle < ApplicationRecord
  belongs_to :user

  enum :status, %i[ pending processing delivered ]

  scope :due, -> { pending.where("ends_at <= ?", Time.current) }
  scope :containing, ->(notification) {
    where("starts_at <= ? AND ends_at > ?", notification.created_at, notification.created_at)
  }

  # Query notifications in the window dynamically - no foreign keys needed!
  def notifications
    user.notifications.where(created_at: window).unread
  end

  private
    def window
      starts_at..ends_at
    end
end
```

**Key insights**:
- No foreign key from Notification to Bundle (simpler schema)
- Notifications are immutable, so querying by time window is reliable
- Window boundaries prevent overlaps (enforced via validation)
- Status enum tracks lifecycle: `pending` → `processing` → `delivered`

**Validation to prevent overlapping bundles**:
```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
validate :validate_no_overlapping

def validate_no_overlapping
  if overlapping_bundles.exists?
    errors.add(:base, "Bundle window overlaps with an existing pending bundle")
  end
end

def overlapping_bundles
  user.notification_bundles
    .where.not(id: id)
    .overlapping_with(self)
end
```

---

## 3. User Preference Architecture with Settings Model

**Pattern**: Extract user settings into a separate model rather than adding columns to User.

**Why it matters**: Keeps User model focused, makes settings easier to test, and enables settings-specific logic.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
module User::Configurable
  extend ActiveSupport::Concern

  included do
    has_one :settings, class_name: "User::Settings", dependent: :destroy
    after_create :create_settings, unless: :system?
  end
end

class User::Settings < ApplicationRecord
  belongs_to :user

  enum :bundle_email_frequency, %i[ never every_few_hours daily weekly ],
    default: :every_few_hours, prefix: :bundle_email

  # Settings-specific business logic lives here
  def bundle_aggregation_period
    case bundle_email_frequency
    when "every_few_hours" then 4.hours
    when "daily" then 1.day
    when "weekly" then 1.week
    else 1.day
    end
  end

  def bundling_emails?
    !bundle_email_never?
  end
end
```

**Benefits**:
- Avoids bloating User table with preference columns
- Settings logic is encapsulated and testable
- Easy to add new settings without touching User model
- Clean separation of concerns

**Reactive settings changes**:
```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
after_update :review_pending_bundles, if: :saved_change_to_bundle_email_frequency?

def review_pending_bundles
  if bundling_emails?
    flush_pending_bundles  # Deliver all pending
  else
    cancel_pending_bundles  # Delete all pending
  end
end
```

---

## 4. Automatic Bundling via Callbacks

**Pattern**: Automatically bundle new notifications via `after_create` callback.

**Why it matters**: Zero-touch bundling - developers creating notifications don't need to remember to bundle.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
class Notification < ApplicationRecord
  after_create :bundle

  private
    def bundle
      user.bundle(self) if user.settings.bundling_emails?
    end
end

module User::Notifiable
  def bundle(notification)
    transaction do
      find_or_create_bundle_for(notification)
    end
  end

  private
    def find_or_create_bundle_for(notification)
      find_bundle_for(notification) || create_bundle_for(notification)
    end

    def find_bundle_for(notification)
      notification_bundles.pending.containing(notification).last
    end

    def create_bundle_for(notification)
      notification_bundles.create!(starts_at: notification.created_at)
    end
end
```

**Key insight**: Bundle creation is idempotent - finds existing bundle in same time window or creates new one.

---

## 5. Background Job Pattern for Batch Delivery

**Pattern**: Use nested jobs - one coordinator job that spawns individual delivery jobs.

**Why it matters**: Parallelizes delivery while managing memory and avoiding timeouts.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
class Notification::Bundle::DeliverAllJob < ApplicationJob
  queue_as :backend

  def perform
    ApplicationRecord.with_each_tenant do |tenant|
      Notification::Bundle.deliver_all
    end
  end
end

class Notification::Bundle
  def self.deliver_all
    due.in_batches do |batch|
      jobs = batch.collect { DeliverJob.new(it) }
      ActiveJob.perform_all_later jobs  # Bulk enqueue for efficiency
    end
  end
end

class Notification::Bundle::DeliverJob < ApplicationJob
  queue_as :backend

  def perform(bundle)
    bundle.deliver
  end
end
```

**Benefits**:
- Coordinator job handles multi-tenancy and batching logic
- Individual delivery jobs are small, fast, and retriable
- `perform_all_later` bulk-enqueues for better performance
- Easy to monitor/retry individual deliveries

**Recurring job configuration**:
```yaml
# config/recurring.yml (Solid Queue)
deliver_bundled_notifications:
  command: "Notification::Bundle.deliver_all_later"
  schedule: every 30 minutes
```

---

## 6. Real-Time Notifications with React + ActionCable

**Pattern**: Use ActionCable for real-time updates with React components triggering Inertia partial reloads.

**Why it matters**: Notifications stay in sync across browser tabs without polling.

### ActionCable Channel

```ruby
# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end

# Model broadcasts event data (not DOM fragments)
class Notification < ApplicationRecord
  after_create_commit :broadcast_new

  def read
    update!(read_at: Time.current)
    broadcast_read
  end

  private
    def broadcast_new
      NotificationsChannel.broadcast_to(user, {
        type: 'notification_added',
        notification_id: id
      })
    end

    def broadcast_read
      NotificationsChannel.broadcast_to(user, {
        type: 'notification_read',
        notification_id: id
      })
    end
end
```

### React Hook for Real-Time Updates

```tsx
import { useEffect } from 'react'
import { usePage, router } from '@inertiajs/react'
import { PageProps } from '@/types'
import consumer from '@/channels/consumer'

function useNotifications() {
  const { auth } = usePage<PageProps>().props

  useEffect(() => {
    if (!auth.user) return

    const channel = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      {
        received(data: { type: string }) {
          // Trigger Inertia partial reload
          router.reload({ only: ['notifications', 'unread_count'] })
        }
      }
    )

    return () => channel.unsubscribe()
  }, [auth.user?.id])
}
```

### Notification Bell Component

```tsx
import { RiBellLine } from '@remixicon/react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

function NotificationBell({ unreadCount }: { unreadCount: number }) {
  return (
    <Button variant="ghost" className="relative">
      <RiBellLine className="w-5 h-5" />
      {unreadCount > 0 && (
        <Badge className="absolute -top-1 -right-1 h-5 w-5 text-xs">
          {unreadCount}
        </Badge>
      )}
    </Button>
  )
}
```

**Key insight**: Broadcasting event data (not DOM) lets React components decide how to update. Inertia's partial reload refreshes only the notification-related props.

---

## 7. Pagination with Infinite Scroll in React

**Pattern**: Use IntersectionObserver hook for automatic pagination with Inertia.

**Why it matters**: Progressive loading without "Load More" buttons or complex state management.

```tsx
import { useEffect, useRef, useState } from 'react'
import { router, usePage } from '@inertiajs/react'

interface PaginationMeta {
  page: number
  pages: number
  next: number | null
}

function useInfiniteScroll(pagination: PaginationMeta) {
  const loadingRef = useRef<HTMLDivElement>(null)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (!loadingRef.current || !pagination.next) return

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !isLoading) {
          setIsLoading(true)
          router.get(
            window.location.pathname,
            { page: pagination.next },
            {
              preserveState: true,
              preserveScroll: true,
              only: ['notifications', 'pagination'],
              onFinish: () => setIsLoading(false)
            }
          )
        }
      },
      { threshold: 0.1 }
    )

    observer.observe(loadingRef.current)
    return () => observer.disconnect()
  }, [pagination.next, isLoading])

  return { loadingRef, isLoading }
}

// Usage in component
function NotificationsList({ notifications, pagination }: Props) {
  const { loadingRef, isLoading } = useInfiniteScroll(pagination)

  return (
    <div className="space-y-2">
      {notifications.map(notification => (
        <NotificationCard key={notification.id} notification={notification} />
      ))}

      {pagination.next && (
        <div ref={loadingRef} className="py-4 text-center">
          {isLoading && <Spinner />}
        </div>
      )}
    </div>
  )
}
```

**Controller response**:
```ruby
def index
  @pagy, @notifications = pagy(Current.user.notifications.ordered)

  render inertia: "Notifications/Index", props: {
    notifications: serialize_notifications(@notifications),
    pagination: pagy_metadata(@pagy)
  }
end
```

---

## 8. Client-Side Notification Grouping with React

**Pattern**: Group notifications by subject (e.g., card) using React state and useMemo.

**Why it matters**: Reduces clutter in notification tray, works dynamically with new notifications.

```tsx
import { useMemo, useState } from 'react'

type Notification = {
  id: string
  card_id: string
  card_title: string
  created_at: string
  // ... other fields
}

function useGroupedNotifications(notifications: Notification[]) {
  return useMemo(() => {
    const groups: Record<string, Notification[]> = {}

    notifications.forEach(notification => {
      const cardId = notification.card_id
      if (!groups[cardId]) {
        groups[cardId] = []
      }
      groups[cardId].push(notification)
    })

    // Sort each group by timestamp, oldest first
    Object.values(groups).forEach(group => {
      group.sort((a, b) =>
        new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
      )
    })

    return groups
  }, [notifications])
}

// Usage in component
function NotificationTray({ notifications }: { notifications: Notification[] }) {
  const groupedNotifications = useGroupedNotifications(notifications)
  const [expandedCards, setExpandedCards] = useState<Set<string>>(new Set())

  const toggleCard = (cardId: string) => {
    setExpandedCards(prev => {
      const next = new Set(prev)
      if (next.has(cardId)) {
        next.delete(cardId)
      } else {
        next.add(cardId)
      }
      return next
    })
  }

  return (
    <div className="space-y-2">
      {Object.entries(groupedNotifications).map(([cardId, group]) => (
        <div key={cardId}>
          <NotificationCard
            notification={group[0]}
            groupCount={group.length}
            onExpand={() => toggleCard(cardId)}
          />
          {expandedCards.has(cardId) && group.length > 1 && (
            <div className="ml-4 space-y-1">
              {group.slice(1).map(n => (
                <NotificationCard key={n.id} notification={n} />
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  )
}
```

**Why client-side grouping?**:
- Works dynamically with real-time notifications via ActionCable
- Server-side grouping is complex when notifications have polymorphic sources
- Avoids database queries to unify notifications by subject
- UI-only concern - no need to persist grouping state

---

## 9. RESTful Controller Design for Notification Actions

**Pattern**: Model notification actions as resources with dedicated controllers.

**Why it matters**: Follows Rails conventions, clearer routing, easier to test.

```ruby
# From PR [#405](https://github.com/basecamp/fizzy/pull/405) - Refactored from custom actions to resourceful routes

# BEFORE: Custom actions on NotificationsController
post "notifications/:id/mark_read"
post "notifications/mark_all_read"

# AFTER: RESTful resources
resources :notifications, only: [:index] do
  resource :reading, only: [:create], module: :notifications
end
namespace :notifications do
  resource :readings, only: [] do
    post :create_all
  end
end

# Dedicated controllers
class Notifications::ReadingsController < ApplicationController
  def create
    @notification = Current.user.notifications.find(params[:id])
    @notification.read
  end

  def create_all
    Current.user.notifications.unread.read_all
    redirect_to notifications_path
  end
end
```

**Benefits**:
- `readings` resource models "the act of reading"
- Clearer intent: creating a reading vs. marking as read
- Easier to add before/after actions specific to reading
- Follows REST principles

---

## 10. Email Unsubscribe with Signed Tokens

**Pattern**: Use Rails 7.1+ `generates_token_for` for secure, self-contained unsubscribe links.

**Why it matters**: Stateless tokens that expire automatically, no database lookups needed for validation.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
module User::Notifiable
  included do
    generates_token_for :unsubscribe, expires_in: 1.month
  end
end

class Notification::BundleMailer < ApplicationMailer
  include Mailers::Unsubscribable

  def notification(bundle)
    @user = bundle.user
    @unsubscribe_token = @user.generate_token_for(:unsubscribe)

    mail to: bundle.user.email_address, subject: "Latest Activity"
  end
end

module Mailers::Unsubscribable
  included do
    after_action :set_unsubscribe_headers
  end

  def set_unsubscribe_headers
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
    headers["List-Unsubscribe"] = "<#{notifications_unsubscribe_url(access_token: @unsubscribe_token)}>"
  end
end
```

**Unsubscribe controller**:
```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
class Notifications::UnsubscribesController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  before_action :set_user

  def create
    @user.settings.bundle_email_never!
    redirect_to notifications_unsubscribe_path(access_token: params[:access_token])
  end

  private
    def set_user
      unless @user = User.find_by_token_for(:unsubscribe, params[:access_token])
        redirect_to root_path, alert: "Invalid unsubscribe link"
      end
    end
end
```

**Key features**:
- RFC-compliant `List-Unsubscribe` headers for email clients
- Self-expiring tokens (no manual cleanup needed)
- Works without authentication session
- CSRF protection skipped (POST with signed token is sufficient)

---

## 11. Email Layout with Inline Styles

**Pattern**: Use table-based layout with inline styles for email compatibility.

**Why it matters**: Ensures emails render consistently across all email clients.

```erb
<!-- From PR [#974](https://github.com/basecamp/fizzy/pull/974) -->
<table>
  <tr>
    <td class="avatar__container">
      <%= mail_avatar_tag(notification.creator) %>
    </td>
    <td>
      <%= render "notification/bundle_mailer/#{notification.source_type.underscore}/body",
                 notification: notification %>
    </td>
  </tr>
</table>
```

**CSS in layout**:
```html
<style>
  .avatar__container {
    vertical-align: top;
    width: 3em;
  }

  .notification__author {
    font-size: 0.8em;
    opacity: 0.66;
    margin: 0;
  }
</style>
```

**Group notifications by subject in email** (PR [#1574](https://github.com/basecamp/fizzy/pull/1574)):
```erb
<!-- Aggregate by card to reduce email clutter -->
<% @notifications.group_by(&:card).each do |card, notifications| %>
  <h2 class="notification__board"><%= card.board.name %></h2>
  <%= link_to "##{ card.id } #{ card.title }", card, class: "card__title" %>
  <%= render partial: "notification/bundle_mailer/notification",
             collection: notifications, as: :notification %>
<% end %>
```

---

## 12. Testing Notification Delivery

**Pattern**: Test time windows, bundling behavior, and state transitions.

```ruby
# From PR [#974](https://github.com/basecamp/fizzy/pull/974)
class Notification::BundleTest < ActiveSupport::TestCase
  setup do
    @user = users(:david)
    @user.settings.bundle_email_every_few_hours!
  end

  test "notifications are bundled within the aggregation period" do
    notification_1 = assert_difference -> { @user.notification_bundles.pending.count }, 1 do
      @user.notifications.create!(source: events(:logo_published), creator: @user)
    end

    travel_to 3.hours.from_now

    notification_2 = assert_no_difference -> { @user.notification_bundles.count } do
      @user.notifications.create!(source: events(:logo_published), creator: @user)
    end

    travel_to 3.days.from_now

    notification_3 = assert_difference -> { @user.notification_bundles.pending.count }, 1 do
      @user.notifications.create!(source: events(:logo_published), creator: @user)
    end

    bundle_1, bundle_2 = @user.notification_bundles.last(2)
    assert_includes bundle_1.notifications, notification_1
    assert_includes bundle_1.notifications, notification_2
    assert_includes bundle_2.notifications, notification_3
  end

  test "overlapping bundles are invalid" do
    bundle_1 = @user.notification_bundles.create!(
      starts_at: Time.current,
      ends_at: 1.hour.from_now
    )

    bundle_2 = @user.notification_bundles.build(
      starts_at: 30.minutes.from_now,
      ends_at: 90.minutes.from_now
    )

    assert_not bundle_2.valid?
    assert_includes bundle_2.errors[:base], "Bundle window overlaps with an existing pending bundle"
  end
end
```

**Key testing insights**:
- Use `travel_to` to test time-based bundling
- Test both positive (included) and negative (excluded) cases
- Verify window overlap validations
- Test settings changes trigger appropriate actions

---

## Summary: Key Architectural Decisions

| Decision | Pattern | Benefit |
|----------|---------|---------|
| **Read state** | `read_at` timestamp | Temporal queries, analytics-ready |
| **Bundling** | Time window queries | Lightweight, no foreign keys |
| **Settings** | Dedicated Settings model | Keeps User focused, extensible |
| **Automation** | `after_create` bundling | Zero-touch for developers |
| **Delivery** | Nested background jobs | Parallelized, retriable |
| **Real-time** | ActionCable + React hooks | Multi-tab sync without polling |
| **Pagination** | React IntersectionObserver | Progressive loading, no buttons |
| **Grouping** | React useMemo + state | Dynamic, works with real-time |
| **Controllers** | RESTful resources | Clean routing, testable |
| **Unsubscribe** | Signed tokens | Stateless, self-expiring |
| **Email** | Grouped by subject | Reduced clutter |
| **Testing** | Time travel + windows | Verify bundling logic |

---

## Further Reading

- **PR [#208](https://github.com/basecamp/fizzy/pull/208)**: Notification index with pagination
- **PR [#306](https://github.com/basecamp/fizzy/pull/306)**: Quieter notifications (subscription vs. watching)
- **PR [#405](https://github.com/basecamp/fizzy/pull/405)**: Refactored to RESTful controllers
- **PR [#475](https://github.com/basecamp/fizzy/pull/475)**: Broadcasting notification reads
- **PR [#974](https://github.com/basecamp/fizzy/pull/974)**: Full bundled email implementation
- **PR [#1448](https://github.com/basecamp/fizzy/pull/1448)**: Client-side grouping by card
- **PR [#1574](https://github.com/basecamp/fizzy/pull/1574)**: Email grouping by card
