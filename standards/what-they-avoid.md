# What They Deliberately Avoid

> Patterns and gems 37signals chooses NOT to use.

---

## Notable Absences

The Fizzy codebase is interesting as much for what's missing as what's present.

## Authentication: No Devise

**Instead**: ~150 lines of custom passwordless magic link code.

**Why avoid Devise**:
- Too heavyweight for passwordless auth
- Comes with password complexity they don't need
- Custom code is simpler to understand and modify

See [authentication.md](authentication.md) for the pattern.

## Authorization: No Pundit/CanCanCan

**Instead**: Simple predicate methods on models.

```ruby
# No policy objects - just model methods
class Card < ApplicationRecord
  def editable_by?(user)
    !closed? && (creator == user || user.admin?)
  end

  def deletable_by?(user)
    user.admin? || creator == user
  end
end

# In controller
def edit
  head :forbidden unless @card.editable_by?(Current.user)
end
```

**Why avoid authorization gems**:
- Simple predicates are easier to understand
- No separate policy files to maintain
- Logic lives with the model it protects

## Service Objects

**Instead**: Rich domain models with focused methods.

```ruby
# Bad - service object
class CardCloser
  def initialize(card, user)
    @card = card
    @user = user
  end

  def call
    @card.update!(closed: true, closed_by: @user)
    NotifyWatchersJob.perform_later(@card)
    @card
  end
end

# Good - model method
class Card < ApplicationRecord
  def close(by:)
    transaction do
      create_closure!(creator: by)
      notify_watchers_later
    end
  end
end
```

**Why avoid service objects**:
- They fragment domain logic across files
- Models become anemic (just data, no behavior)
- Simple operations don't need coordination objects

## Form Objects

**Instead**: Strong parameters and model validations.

```ruby
# No form objects - just params.expect
def create
  @card = @board.cards.create!(card_params)
end

private
  def card_params
    params.expect(card: [:title, :description, { tag_ids: [] }])
  end
```

**When form objects might be justified**: Complex multi-model forms. But even then, consider if nested attributes suffice.

## Decorators/Presenters

**Instead**: View helpers and partials.

```ruby
# No decorator gems
# Just helpers for view logic
module CardsHelper
  def card_status_badge(card)
    if card.closed?
      tag.span "Closed", class: "badge badge--closed"
    elsif card.overdue?
      tag.span "Overdue", class: "badge badge--warning"
    end
  end
end
```

## ViewComponent

**For React pages**: Use shadcn/ui components.

```tsx
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

<Card>
  <CardContent>
    <Button variant="outline">Action</Button>
  </CardContent>
</Card>
```

**For ERB pages**: Use partials with locals.

```erb
<%= render "cards/preview", card: @card, draggable: true %>
```

**Why**:
- shadcn/ui provides accessible, consistent React components
- Components are copy-pasted into codebase (not npm dependency)
- ERB partials remain simpler for server-rendered pages

## GraphQL

**Instead**: REST endpoints with Inertia.

**Why avoid GraphQL**:
- Adds complexity for uncertain benefit
- REST + Inertia handles their needs
- No mobile app requiring flexible queries

## Sidekiq

**Instead**: Solid Queue (database-backed).

**Why avoid Sidekiq**:
- Removes Redis dependency
- Database is already managed
- Good enough for their scale

## Client-Side Routing (React Router, etc.)

**Instead**: Inertia.js + React with server-side routing.

We use React with Inertia.js, which provides:
- SPA-like experience without client-side routing
- Server controls navigation (Rails routes)
- No Redux/Zustand - props passed from controllers
- TypeScript for type-safe development

```ruby
# Rails controller renders React component
render inertia: "Discovery/Show", props: {
  workstation: serialize_workstation(@workstation)
}
```

**Why avoid client-side routing**:
- Rails routes remain the source of truth
- No route synchronization issues
- Simpler mental model
- Server-side redirects work naturally

See [Inertia.js + React](inertia-react.md) for patterns.

## Tailwind CSS (Updated Position)

**We now use Tailwind CSS** with shadcn/ui components.

```tsx
<div className="flex items-center gap-4 p-4 rounded-lg bg-card">
  <Badge variant="outline">Active</Badge>
  <Button variant="ghost">Action</Button>
</div>
```

**Why we adopted Tailwind**:
- shadcn/ui is built on Tailwind - excellent component library
- Utility classes compose well with React
- CSS custom properties for theming (semantic colors)
- `cn()` utility handles conditional classes elegantly

**We still prefer semantic patterns**:
- Use theme colors: `text-muted-foreground`, not `text-gray-500`
- Use CVA variants for component states
- Extract repeated patterns to components

See [CSS & Styling](css.md) for configuration.

## RSpec

**Instead**: Minitest (ships with Rails).

**Why avoid RSpec**:
- Minitest is simpler, less DSL
- Faster boot time
- Good enough assertions

## FactoryBot

**Instead**: Fixtures.

**Why avoid factories**:
- Fixtures are faster (loaded once)
- Relationships are explicit in YAML
- Deterministic test data

## The Philosophy

> "We reach for gems when Rails doesn't provide a solution. But Rails provides most solutions."

Before adding a dependency, ask:
1. Can vanilla Rails do this?
2. Is the complexity worth the benefit?
3. Will we need to maintain this dependency?
4. Does it make the codebase harder to understand?

## What We DO Use

### Frontend Stack (Inertia + React)

- `inertia_rails` - Connect Rails controllers to React components
- `@inertiajs/react` - Inertia React adapter
- `react`, `react-dom` - React library
- `@radix-ui/*` - Headless UI primitives (via shadcn/ui)
- `tailwindcss` - Utility-first CSS
- `class-variance-authority` - Component variants
- `@remixicon/react` - Icon library
- `vite`, `vite-plugin-ruby` - Fast build tool

### Backend Infrastructure

- `solid_queue`, `solid_cache`, `solid_cable` - Database-backed infrastructure
- `propshaft` - Simple asset pipeline
- `kamal` - Deployment
- `bcrypt` - Password hashing
- `image_processing` - Active Storage variants
- `pagy` - Pagination

The bar is high. Each dependency must clearly earn its place.
