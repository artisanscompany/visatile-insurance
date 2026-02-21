# Core Principles

> The absolutely most important patterns extracted from the standards.

---

## Routes

### Routes Must Always Be RESTful

Every action maps to a CRUD verb. When something doesn't fit, create a new resource.

```ruby
# BAD: Custom actions
resources :cards do
  post :close
  post :archive
end

# GOOD: New resources for state changes
resources :cards do
  resource :closure    # POST to close, DELETE to reopen
  resource :archive    # POST to archive, DELETE to unarchive
end
```

### Verbs Become Nouns

| Action | Resource |
|--------|----------|
| Close a card | `card.closure` |
| Publish a board | `board.publication` |
| Pin an item | `item.pin` |
| Accept invitation | `invitation.acceptance` |
| Approve submission | `submission.approval` |

### Key Rules

1. **Always RESTful** - No custom actions, only CRUD
2. **Shallow nesting** - Avoid URLs like `/a/1/b/2/c/3`
3. **Singular when appropriate** - `resource` for one-per-parent
4. **Module scoping** - Group controllers without changing URLs

---

## Models & Controllers

### Thin Controllers, Rich Models

```ruby
# GOOD: Controller orchestrates, model does work
def create
  @card.close
  redirect_to card_path(@card)
end

# BAD: Business logic in controller
def create
  @card.transaction do
    @card.create_closure!(user: Current.user)
    @card.events.create!(action: :closed)
  end
end
```

### Relationships as Records, Not Booleans

Instead of `closed: boolean` or `accepted: boolean`, create a separate record. This applies to **any relationship** that needs to track context:

```ruby
# Task states - each is a separate record
class Task < ApplicationRecord
  has_one :start, dependent: :destroy
  has_one :completion, dependent: :destroy
  has_one :cancellation, dependent: :destroy

  scope :pending, -> { where.missing(:start) }
  scope :running, -> { joins(:start).where.missing(:completion, :cancellation) }
  scope :completed, -> { joins(:completion) }
  scope :cancelled, -> { joins(:cancellation) }
end

# Invitation responses - acceptance/decline are records
class CalendarInvitation < ApplicationRecord
  has_one :calendar_acceptance, dependent: :destroy
  has_one :calendar_decline, dependent: :destroy

  def accepted? = calendar_acceptance.present?
  def declined? = calendar_decline.present?
  def pending? = !responded?
end

# Approval flow - approval/rejection are records
class ApprovalSubmission < ApplicationRecord
  has_one :approval, dependent: :destroy
  has_one :rejection, dependent: :destroy

  def approved? = approval.present?
  def rejected? = rejection.present?
end
```

**Why**: Each record captures who did it, when, and any additional context (reason, note, etc.).

### Concerns for Horizontal Behavior

```ruby
class Card < ApplicationRecord
  include Closeable, Watchable, Assignable, Taggable

  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
end
```

### Key Rules

1. **Business logic in models** - Controllers just orchestrate
2. **Relationships as records** - Track who, when, what, why
3. **Concerns are self-contained** - 50-150 lines, one capability
4. **Default values via lambdas** - `default: -> { Current.user }`
5. **Bang methods everywhere** - `create!` raises on failure
6. **Semantic scope names** - `active` not `not_deleted`

---

## Views

### Inertia.js Architecture

```
Rails Controller → render inertia: "Page/Path" → React Component
```

No API layer. Props passed directly from controllers.

### Page Structure

```tsx
interface Props {
  design: Design
  pages: Page[]
}

export default function Editor({ design, pages }: Props) {
  return (
    <DashboardLayout title="Editor">
      <Head title={design.name} />
      {/* Content */}
    </DashboardLayout>
  )
}
```

### Key Rules

1. **Type all props** - TypeScript for everything
2. **Use layouts** - `DashboardLayout` or `PublicLayout`
3. **shadcn/ui components** - Consistent, accessible UI
4. **Semantic colors** - `text-muted-foreground`, not `text-gray-500`
5. **Mobile-first** - Start mobile, add breakpoints
6. **Use `cn()`** - Merge Tailwind classes conditionally

### The `cn()` Utility

```tsx
<div className={cn(
  'p-4 rounded-lg',
  isActive && 'bg-primary',
  isDisabled && 'opacity-50'
)}>
```

---

## Universal Principles

### Fix Root Causes

```ruby
# BAD: Retry logic for race conditions
# GOOD: Use enqueue_after_transaction_commit to prevent the race

# BAD: Work around CSRF issues on cached pages
# GOOD: Don't HTTP cache pages with forms
```

### When to Extract

- Start in controller, extract when messy
- Rule of three: duplicate twice before abstracting
- Concerns must earn their keep - 3+ variations needed

### Write-Time Over Read-Time

- Pre-compute roll-ups at write time
- Use counter caches instead of counting at read time
- Manipulate data when saving, not when presenting
