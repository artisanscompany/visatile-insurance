# Controllers

> Thin controllers, rich models, and composable concerns.

---

## Core Principle: Thin Controllers, Rich Models

Controllers should be thin orchestrators. Business logic lives in models.

```ruby
# GOOD: Controller just orchestrates
class Cards::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close  # All logic in model

    redirect_to card_path(@card), notice: "Card closed"
    # Or for Inertia pages:
    # render inertia: "Cards/Show", props: { card: serialize_card(@card) }
  end

  def destroy
    @card.reopen  # All logic in model

    redirect_to card_path(@card), notice: "Card reopened"
  end
end
```

```ruby
# BAD: Business logic in controller
class Cards::ClosuresController < ApplicationController
  def create
    @card.transaction do
      @card.create_closure!(user: Current.user)
      @card.events.create!(action: :closed, creator: Current.user)
      @card.watchers.each { |w| NotificationMailer.card_closed(w, @card).deliver_later }
    end
  end
end
```

## ApplicationController is Minimal

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include BlockSearchEngineIndexing
  include CurrentRequest, CurrentTimezone, SetPlatform
  include RequestForgeryProtection
  include RoutingHeaders

  etag { "v1" }
  stale_when_importmap_changes
  allow_browser versions: :modern
end
```

## Authorization: Controller Checks, Model Defines

```ruby
# Controller checks permission
class CardsController < ApplicationController
  before_action :ensure_permission_to_administer_card, only: [:destroy]

  private
    def ensure_permission_to_administer_card
      head :forbidden unless Current.user.can_administer_card?(@card)
    end
end

# Model defines what permission means
class User < ApplicationRecord
  def can_administer_card?(card)
    admin? || card.creator == self
  end

  def can_administer_board?(board)
    admin? || board.creator == self
  end
end
```

---

## Controller Concerns Catalog

Controller concerns create a vocabulary of reusable behaviors that compose beautifully.

### Resource Scoping Concerns

#### CardScoped - For Card Sub-resources

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

    def serialize_card(card)
      {
        id: card.id,
        number: card.number,
        title: card.title,
        closed: card.closed?,
        board_id: card.board_id
      }
    end
end
```

**Usage Pattern:**

```ruby
# Any controller nested under cards uses this
class Cards::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close
    redirect_to card_path(@card), notice: "Card closed"
  end
end

class Cards::WatchesController < ApplicationController
  include CardScoped

  def create
    @card.watch_by Current.user
    # ...
  end
end

class Cards::PinsController < ApplicationController
  include CardScoped

  def create
    @pin = @card.pin_by Current.user
    # ...
  end
end
```

**Key insight:** The concern provides `serialize_card` - a shared way to prepare card data for responses.

#### BoardScoped - For Board Sub-resources

```ruby
# app/controllers/concerns/board_scoped.rb
module BoardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_board
  end

  private
    def set_board
      @board = Current.user.boards.find(params[:board_id])
    end

    def ensure_permission_to_admin_board
      unless Current.user.can_administer_board?(@board)
        head :forbidden
      end
    end
end
```

**Usage:**

```ruby
class Boards::ColumnsController < ApplicationController
  include BoardScoped

  def create
    @column = @board.columns.create!(column_params)
  end
end

class Boards::PublicationsController < ApplicationController
  include BoardScoped
  before_action :ensure_permission_to_admin_board

  def create
    @board.publish
  end
end
```

#### ColumnScoped - For Column Sub-resources

```ruby
# app/controllers/concerns/column_scoped.rb
module ColumnScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_column
  end

  private
    def set_column
      @column = Current.user.accessible_columns.find(params[:column_id])
    end
end
```

---

### Request Context Concerns

#### CurrentRequest - Populate Current with Request Data

```ruby
# app/controllers/concerns/current_request.rb
module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.http_method = request.method
      Current.request_id  = request.uuid
      Current.user_agent  = request.user_agent
      Current.ip_address  = request.ip
      Current.referrer    = request.referrer
    end
  end
end
```

**Why this matters:** Models and jobs can access request context via `Current` without parameter passing:

```ruby
class Signup
  def create_identity
    Identity.create!(
      email_address: email_address,
      # These come from Current, not parameters!
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end
end
```

#### CurrentTimezone - User Timezone from Cookie

```ruby
# app/controllers/concerns/current_timezone.rb
module CurrentTimezone
  extend ActiveSupport::Concern

  included do
    around_action :set_current_timezone
    helper_method :timezone_from_cookie
    etag { timezone_from_cookie }
  end

  private
    def set_current_timezone(&)
      Time.use_zone(timezone_from_cookie, &)
    end

    def timezone_from_cookie
      @timezone_from_cookie ||= begin
        timezone = cookies[:timezone]
        ActiveSupport::TimeZone[timezone] if timezone.present?
      end
    end
end
```

**Key patterns:**
1. `around_action` wraps the entire request in the user's timezone
2. `etag` includes timezone - different timezones get different cached responses
3. `helper_method` makes it available in views
4. Cookie is set client-side by JavaScript detecting the user's timezone

#### SetPlatform - Detect Mobile/Desktop

```ruby
# app/controllers/concerns/set_platform.rb
module SetPlatform
  extend ActiveSupport::Concern

  included do
    helper_method :platform
  end

  private
    def platform
      @platform ||= ApplicationPlatform.new(request.user_agent)
    end
end
```

**Usage in views:**

```erb
<% if platform.mobile? %>
  <%= render "mobile_nav" %>
<% else %>
  <%= render "desktop_nav" %>
<% end %>
```

---

### Filtering & Pagination Concerns

#### FilterScoped - Complex Filtering

```ruby
# app/controllers/concerns/filter_scoped.rb
module FilterScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_filter
    before_action :set_user_filtering
  end

  private
    def set_filter
      if params[:filter_id].present?
        @filter = Current.user.filters.find(params[:filter_id])
      else
        @filter = Current.user.filters.from_params(filter_params)
      end
    end

    def filter_params
      params.reverse_merge(**Filter.default_values)
            .permit(*Filter::PERMITTED_PARAMS)
    end

    def set_user_filtering
      @user_filtering = User::Filtering.new(Current.user, @filter, expanded: expanded_param)
    end
end
```

**The Filter model does the heavy lifting:**

```ruby
class Filter < ApplicationRecord
  def cards
    result = creator.accessible_cards.preloaded.published
    result = result.indexed_by(indexed_by)
    result = result.sorted_by(sorted_by)
    result = result.where(board: boards.ids) if boards.present?
    result = result.tagged_with(tags.ids) if tags.present?
    result = result.assigned_to(assignees.ids) if assignees.present?
    # ... more filtering
    result.distinct
  end
end
```

**Pattern:** Filters are persisted! Users can save and name their filters.

---

### Security & Headers Concerns

#### BlockSearchEngineIndexing - Prevent Crawling

```ruby
# app/controllers/concerns/block_search_engine_indexing.rb
module BlockSearchEngineIndexing
  extend ActiveSupport::Concern

  included do
    after_action :block_search_engine_indexing
  end

  private
    def block_search_engine_indexing
      headers["X-Robots-Tag"] = "none"
    end
end
```

**Why:** Private app content shouldn't appear in search results.

#### RequestForgeryProtection - Modern CSRF

```ruby
# app/controllers/concerns/request_forgery_protection.rb
module RequestForgeryProtection
  extend ActiveSupport::Concern

  included do
    after_action :append_sec_fetch_site_to_vary_header
  end

  private
    def append_sec_fetch_site_to_vary_header
      vary_header = response.headers["Vary"].to_s.split(",").map(&:strip).reject(&:blank?)
      response.headers["Vary"] = (vary_header + ["Sec-Fetch-Site"]).join(",")
    end

    def verified_request?
      request.get? || request.head? || !protect_against_forgery? ||
        (valid_request_origin? && safe_fetch_site?)
    end

    SAFE_FETCH_SITES = %w[same-origin same-site]

    def safe_fetch_site?
      SAFE_FETCH_SITES.include?(sec_fetch_site_value) ||
        (sec_fetch_site_value.nil? && api_request?)
    end

    def api_request?
      request.format.json?
    end
end
```

**Modern approach:** Uses `Sec-Fetch-Site` header instead of tokens. Browsers set this automatically.

---

## Composing Concerns: Real Controllers

Here's how concerns compose in practice:

```ruby
# A full-featured nested controller
class Cards::AssignmentsController < ApplicationController
  include CardScoped  # Gets @card, @board, serialize_card

  def new
    @assigned_to = @card.assignees.active.alphabetically.where.not(id: Current.user)
    @users = @board.users.active.alphabetically.where.not(id: @card.assignees)
    fresh_when etag: [@users, @card.assignees]  # HTTP caching!
  end

  def create
    @card.toggle_assignment @board.users.active.find(params[:assignee_id])

    redirect_to card_path(@card), notice: "Assignment updated"
  end
end
```

```ruby
# A timeline controller composing multiple concerns
class Events::Days::ColumnsController < ApplicationController
  include DayTimelinesScoped  # Which includes FilterScoped

  def show
    @column = @board.columns.find(params[:id])
  end
end
```

## Concern Composition Rules

1. **Concerns can include other concerns:**
   ```ruby
   module DayTimelinesScoped
     include FilterScoped  # Inherits all of FilterScoped
     # ...
   end
   ```

2. **Use `before_action` in `included` block:**
   ```ruby
   included do
     before_action :set_card
   end
   ```

3. **Provide shared private methods:**
   ```ruby
   def serialize_card(card)
     # Reusable across all CardScoped controllers
   end
   ```

4. **Use `helper_method` for view access:**
   ```ruby
   included do
     helper_method :platform, :timezone_from_cookie
   end
   ```

5. **Add to `etag` for HTTP caching:**
   ```ruby
   included do
     etag { timezone_from_cookie }
   end
   ```

---

## Inertia Controllers for React

Controllers that render React pages via Inertia.js follow specific patterns.

### Base Inertia Controller

All Inertia pages inherit from `InertiaController`:

```ruby
# app/controllers/inertia_controller.rb
class InertiaController < ApplicationController
  layout "inertia"

  # Share data with all Inertia responses
  inertia_share do
    account = Current.account || Current.session&.current_account

    {
      auth: {
        user: Current.user&.as_json(only: %i[id name email]),
        account: account&.as_json(only: %i[id name slug type]),
        impersonating: respond_to?(:impersonating?) ? impersonating? : false
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
end
```

### Account-Scoped Inertia Controller

For authenticated dashboard pages with account context:

```ruby
# app/controllers/account_inertia_controller.rb
class AccountInertiaController < InertiaController
  include PrivilegeAuthorization
  include SidebarAuthorization

  before_action :require_authentication
  before_action :set_account
  before_action :set_sidebar_authorization
  before_action :require_account_membership

  # Share account-specific data
  inertia_share do
    {
      account: serialize_current_account,
      sidebar: serialize_sidebar_permissions,
      privileges: serialize_user_privileges
    }
  end

  private

  def set_account
    @account = Current.user.accounts.find_by!(slug: params[:account_id])
    Current.account = @account
  end

  def serialize_current_account
    {
      id: Current.account.id,
      name: Current.account.name,
      slug: Current.account.slug,
      type: Current.account.account_type
    }
  end
end
```

### Rendering Inertia Responses

```ruby
class DiscoveryController < InertiaController
  allow_unauthenticated_access

  def show
    @workstation = Workstation.publicly_available.find(params[:id])

    render inertia: "Discovery/Show", props: {
      workstation: serialize_workstation_detail(@workstation),
      workspace: serialize_workspace(@workstation.workspace),
      booking_options: serialize_booking_options(@workstation)
    }
  end

  private

  def serialize_workstation_detail(workstation)
    {
      id: workstation.id,
      name: workstation.name,
      description: workstation.description,
      workstation_type: workstation.workstation_type,
      capacity: workstation.capacity,
      hourly_rate: workstation.hourly_rate_cents&./(100.0),
      photos: workstation.photos.map { |p| url_for(p) }
    }
  end
end
```

### Props Serialization Guidelines

1. **Use plain Ruby hashes** - No serializer gems needed
2. **Convert money to floats** - `cents / 100.0`
3. **Use `url_for` for attachments** - Active Storage URLs
4. **Flatten nested data** - React prefers flat structures
5. **Include only needed fields** - Don't expose entire models

### Inertia with Concerns

Concerns compose with Inertia controllers just like regular controllers:

```ruby
class Account::BookingsController < AccountInertiaController
  include BookingScoped  # Works the same as before

  def show
    render inertia: "Account/Bookings/Show", props: {
      booking: serialize_booking(@booking)
    }
  end
end
```

### When to Use Each Controller Base

| Base Controller | Use For |
|-----------------|---------|
| `ApplicationController` | ERB views, API endpoints |
| `InertiaController` | Public React pages |
| `AccountInertiaController` | Authenticated dashboard pages |

See [Inertia.js + React](inertia-react.md) for complete frontend patterns.
