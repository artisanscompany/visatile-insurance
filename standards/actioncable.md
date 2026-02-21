# ActionCable

> Multi-tenant WebSockets, broadcast scoping, and Solid Cable.

---

## Connection Management

### Multi-Tenant WebSocket Authentication

**Pattern**: Set tenant context during WebSocket connection establishment, just like HTTP requests.

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        if session = find_session_by_cookie
          account = Account.find_by(external_account_id: request.env["fizzy.external_account_id"])
          Current.account = account
          self.current_user = session.identity.users.find_by!(account: account) if account
        end
      end

      def find_session_by_cookie
        Session.find_signed(cookies.signed[:session_token])
      end
  end
end
```

**Why it matters**: WebSocket connections must establish the same security context as HTTP requests. In multi-tenant apps, this prevents data leakage across tenants.

**Key insights**:
- Extract tenant context from request environment (set by middleware)
- Validate both session AND tenant membership
- Reject connection if either validation fails
- Set `Current.account` so broadcasts respect tenant boundaries

**From**: PR [#699](https://github.com/basecamp/fizzy/pull/699), [#1765](https://github.com/basecamp/fizzy/pull/1765), [#1800](https://github.com/basecamp/fizzy/pull/1800)

### Testing Connection Authentication

```ruby
# test/channels/application_cable/connection_test.rb
module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test "connects with valid session and account info" do
      cookies.signed[:session_token] = @session.signed_id

      connect "/cable", env: { "fizzy.external_account_id" => @account.external_account_id }

      assert_equal users(:mike), connection.current_user
      assert_equal @account, Current.account
    end

    test "rejects with invalid session token" do
      cookies.signed[:session_token] = "invalid-session-id"

      assert_reject_connection do
        connect "/cable", env: { "fizzy.external_account_id" => @account.external_account_id }
      end
    end
  end
end
```

**Why it matters**: Connection tests verify the critical security boundary. Use `ActionCable::Connection::TestCase` to test authentication without a full integration test.

**From**: PR [#1810](https://github.com/basecamp/fizzy/pull/1810)

### Forcibly Disconnect Users

**Pattern**: Use `remote_connections` to disconnect users server-side (e.g., on deactivation).

```ruby
# app/models/user.rb
def deactivate
  transaction do
    accesses.destroy_all
    update! active: false, identity: nil
    close_remote_connections
  end
end

private
  def close_remote_connections
    ActionCable.server.remote_connections.where(current_user: self).disconnect(reconnect: false)
  end
```

**Why it matters**: When users are deactivated, banned, or permissions change, their WebSocket connections must be terminated immediately. The `reconnect: false` flag prevents automatic reconnection attempts.

**Testing consideration**: Mock `close_remote_connections` in unit tests since it requires a running ActionCable server:

```ruby
test "deactivate" do
  users(:jz).tap do |user|
    user.stubs(:close_remote_connections).once
    user.deactivate
  end
end
```

**From**: PR [#1810](https://github.com/basecamp/fizzy/pull/1810)

## Broadcast Strategies

### Dual Broadcasting for Flexibility

**Pattern**: Broadcast to both specific resources AND a catch-all stream for flexible subscription patterns.

```ruby
# app/models/board/broadcastable.rb
module Board::Broadcastable
  extend ActiveSupport::Concern

  included do
    after_create_commit :broadcast_created
    after_update_commit :broadcast_updated
    after_destroy_commit :broadcast_destroyed

    private

    def broadcast_created
      ActionCable.server.broadcast(stream_name, { type: 'board_created', board_id: id })
      ActionCable.server.broadcast(all_boards_stream, { type: 'board_created', board_id: id })
    end

    def stream_name
      "board_#{id}"
    end

    def all_boards_stream
      "account_#{account_id}_all_boards"
    end
  end
end
```

**Why it matters**: This allows React components to subscribe either to specific boards OR to all boards within an account, depending on what data is displayed.

**Usage in React**:

```tsx
import { useEffect } from 'react'
import { router } from '@inertiajs/react'
import consumer from '@/channels/consumer'

function useboardUpdates(boardIds: string[] | null) {
  useEffect(() => {
    const channels: any[] = []

    if (boardIds && boardIds.length > 0) {
      // Subscribe to specific boards when filtering
      boardIds.forEach(id => {
        channels.push(
          consumer.subscriptions.create(
            { channel: 'BoardsChannel', board_id: id },
            { received: () => router.reload({ only: ['boards'] }) }
          )
        )
      })
    } else {
      // Subscribe to all boards when showing everything
      channels.push(
        consumer.subscriptions.create(
          { channel: 'AllBoardsChannel' },
          { received: () => router.reload({ only: ['boards'] }) }
        )
      )
    }

    return () => channels.forEach(ch => ch.unsubscribe())
  }, [boardIds?.join(',')])
}
```

**From**: PR [#1432](https://github.com/basecamp/fizzy/pull/1432), [#1800](https://github.com/basecamp/fizzy/pull/1800)

### Account-Scoped Broadcasts Prevent DoS

**Critical security pattern**: ALWAYS scope general broadcast streams by account/tenant.

```ruby
# WRONG - broadcasts to ALL accounts!
ActionCable.server.broadcast("all_boards", data)

# CORRECT - scoped to current account
ActionCable.server.broadcast("account_#{account.id}_all_boards", data)
```

**Why it matters**: Without account scoping, a single update in one tenant triggers broadcasts to ALL connected clients across ALL tenants. This is a self-DoS vulnerability that can bring down your application under load.

**From**: PR [#1800](https://github.com/basecamp/fizzy/pull/1800) (titled "Scope general broadcasts by account - Because DoS ourselves is not fun")

### Conditional Broadcast Targets

**Pattern**: Use lambdas to dynamically determine broadcast targets based on model state.

```ruby
broadcasts_refreshes_to ->(board) { [ board.account, :all_boards ] }
```

**Why it matters**: Broadcast targets often depend on model attributes. Lambdas allow dynamic resolution while keeping broadcast logic in the model.

**From**: PR [#1765](https://github.com/basecamp/fizzy/pull/1765), [#1800](https://github.com/basecamp/fizzy/pull/1800)

## ActionCable with React

### Broadcasting Individual vs Batch Updates

**Anti-pattern**: Using `update_all` prevents individual broadcasts.

```ruby
# BAD - no broadcasts sent
def self.read_all
  update!(read_at: Time.current)
end

# GOOD - each record broadcasts
def self.read_all
  all.each { |notification| notification.read }
end
```

**Controller pattern**: Return redirect or JSON when broadcasts handle real-time updates.

```ruby
# app/controllers/notifications/readings_controller.rb
def create_all
  Current.user.notifications.unread.read_all
  redirect_to notifications_path, notice: "All marked as read"
end
```

**Why it matters**: Individual model updates trigger `after_commit` callbacks that broadcast changes. When you need the UI to update via ActionCable, iterate instead of batch updating.

**From**: PR [#705](https://github.com/basecamp/fizzy/pull/705)

### Broadcast Event Data (Not DOM)

```ruby
# app/models/notification.rb
after_create_commit :broadcast_created
after_destroy_commit :broadcast_destroyed

def read
  update!(read_at: Time.current)
  broadcast_read
end

private
  def broadcast_created
    NotificationsChannel.broadcast_to(user, {
      type: 'notification_created',
      notification_id: id
    })
  end

  def broadcast_read
    NotificationsChannel.broadcast_to(user, {
      type: 'notification_read',
      notification_id: id
    })
  end
```

**React subscription hook**:

```tsx
function useNotificationUpdates(userId: string) {
  useEffect(() => {
    const channel = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      {
        received(data: { type: string; notification_id: string }) {
          // Trigger Inertia partial reload
          router.reload({ only: ['notifications', 'unread_count'] })
        }
      }
    )
    return () => channel.unsubscribe()
  }, [userId])
}
```

**Why it matters**: Broadcasting event data (not DOM fragments) lets React components decide how to update. This decouples the backend from frontend rendering logic.

**From**: PR [#705](https://github.com/basecamp/fizzy/pull/705)

## Multi-Tenant ActionCable Configuration

### Path-Based Tenancy Cable URL

**Pattern**: Adjust the ActionCable URL to include the tenant path prefix.

```ruby
# app/helpers/tenanting_helper.rb
module TenantingHelper
  def tenanted_action_cable_meta_tag
    tag "meta",
        name: "action-cable-url",
        content: "#{request.script_name}#{ActionCable.server.config.mount_path}"
  end
end
```

**Common mistake**: Avoid double slashes by using string interpolation instead of `join("/")`.

```ruby
# WRONG - creates "/1234567//cable"
content: [ request.script_name, ActionCable.server.config.mount_path ].join("/")

# CORRECT - creates "/1234567/cable"
content: "#{request.script_name}#{ActionCable.server.config.mount_path}"
```

**Why it matters**: In path-based multi-tenancy, the WebSocket URL must include the account path prefix so middleware can extract the tenant context.

**From**: PR [#699](https://github.com/basecamp/fizzy/pull/699)

### Solid Cable for Database-Backed WebSockets

**Pattern**: Use Solid Cable instead of Redis for ActionCable pub/sub.

```yaml
# config/cable.yml
cable: &cable
  adapter: solid_cable
  connects_to:
    database:
      writing: cable
      reading: cable
  polling_interval: 0.1.seconds
  message_retention: 1.day

production: *cable
```

**Database configuration** for separate cable database:

```yaml
# config/database.yml
production:
  primary:
    <<: *default
    database: app_production
  cable:
    <<: *default
    database: app_production_cable
    migrations_paths: db/cable_migrate
```

**Why it matters**: Eliminates Redis dependency while maintaining ActionCable functionality. Solid Cable is production-ready and simplifies deployment.

**Configuration note**: Handle binary column sizes in table definitions:

```ruby
# config/initializers/table_definition_column_limits.rb
if type == :text || type == :binary
  if options.key?(:size)
    size = options.delete(:size)
    options[:limit] ||= TEXT_SIZE_TO_LIMIT.fetch(size)
  end
end
```

**From**: PR [#1765](https://github.com/basecamp/fizzy/pull/1765)

## Monitoring and Metrics

### ActionCable Metrics with Yabeda

**Pattern**: Add ActionCable-specific metrics to your monitoring stack.

```ruby
# Gemfile
gem "yabeda-actioncable"

# config/initializers/yabeda.rb
Yabeda::ActionCable.configure do |config|
  # Focus on your primary channel for cleaner metrics
  config.channel_class_name = "ActionCable::Channel::Base"
end
```

**Recurring measurement** (every 60 seconds):

```yaml
# config/recurring.yml
production:
  yabeda_actioncable:
    command: "Yabeda::ActionCable.measure"
    schedule: every 60 seconds
```

**Why it matters**: Monitor WebSocket connection counts, message rates, and subscription patterns. Critical for diagnosing broadcast performance issues and connection problems.

**From**: PR [#1291](https://github.com/basecamp/fizzy/pull/1291)

## Testing Patterns

### Testing Broadcasts

**Use Rails' built-in ActionCable test helpers**:

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  include ActionCable::TestHelper
end
```

**Test broadcasts in model tests**:

```ruby
test "reading notification broadcasts event" do
  notification = notifications(:logo_published_kevin)

  assert_broadcast_on(
    NotificationsChannel.broadcasting_for(notification.user),
    { type: 'notification_read', notification_id: notification.id }
  ) do
    notification.read
  end
end

test "deleting notification broadcasts its removal" do
  notification = notifications(:logo_published_kevin)

  assert_broadcasts(NotificationsChannel.broadcasting_for(notification.user), 1) do
    notification.destroy
  end
end
```

**Why it matters**: Broadcast failures are silent in production. Testing ensures critical real-time updates actually happen.

**From**: PR [#705](https://github.com/basecamp/fizzy/pull/705), [#1810](https://github.com/basecamp/fizzy/pull/1810)

### Test Adapter Configuration

```yaml
# config/cable.yml
test:
  adapter: test  # Use test adapter, not solid_cable
```

**Why it matters**: The test adapter is synchronous and designed for assertions. Don't use your production adapter in tests.

**From**: PR [#1765](https://github.com/basecamp/fizzy/pull/1765)

## Performance Considerations

### Broadcast Batching

**Pattern**: Use `broadcast_*_later` for async broadcasting outside the request cycle.

```ruby
def broadcast_unread
  broadcast_prepend_later_to user, :notifications, target: "notifications"
end
```

**Why it matters**: Broadcasts can be slow. Using `_later` variants queues the broadcast as a background job, keeping requests fast.

**From**: PR [#705](https://github.com/basecamp/fizzy/pull/705)

### Selective Subscriptions

**Pattern**: Subscribe only to the data visible on the current page.

```tsx
import { useEffect } from 'react'
import { router } from '@inertiajs/react'
import consumer from '@/channels/consumer'

function useCollectionUpdates(collectionIds: string[] | null, accountId: string) {
  useEffect(() => {
    const subscriptions: any[] = []

    if (collectionIds && collectionIds.length > 0) {
      // Filtered view - subscribe only to selected collections
      collectionIds.forEach(id => {
        subscriptions.push(
          consumer.subscriptions.create(
            { channel: 'CollectionChannel', collection_id: id },
            { received: () => router.reload({ only: ['collections'] }) }
          )
        )
      })
    } else {
      // Subscribe to all collections (scoped by account)
      subscriptions.push(
        consumer.subscriptions.create(
          { channel: 'AllCollectionsChannel', account_id: accountId },
          { received: () => router.reload({ only: ['collections'] }) }
        )
      )
    }

    return () => subscriptions.forEach(sub => sub.unsubscribe())
  }, [collectionIds?.join(','), accountId])
}
```

**Why it matters**: Reduces unnecessary WebSocket traffic. Users only receive updates for data they can see.

**From**: PR [#1432](https://github.com/basecamp/fizzy/pull/1432)

## Summary

**Critical takeaways for any Rails app**:

1. **Security first**: Always scope broadcasts by tenant/account in multi-tenant apps
2. **Test connections**: Use `ActionCable::Connection::TestCase` to verify authentication
3. **Dual broadcasts**: Broadcast to both specific resources and catch-all streams for flexibility
4. **Iterate for broadcasts**: Use `.each` instead of `update_all` when broadcasts are needed
5. **Force disconnect**: Use `remote_connections` when permissions change
6. **Monitor it**: Add ActionCable metrics to catch performance issues early
7. **Test broadcasts**: Use `assert_broadcast_on` to ensure updates work
8. **Solid Cable**: Consider database-backed ActionCable instead of Redis for simpler deployments

These patterns are production-tested at scale and apply to any Rails application using ActionCable for real-time features.
