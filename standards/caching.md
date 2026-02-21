# Caching Patterns

> HTTP caching and fragment caching lessons from 37signals.

---

## HTTP Caching (ETags)

### How ETags Work

ETags let the browser avoid re-downloading unchanged content. Here's the flow:

1. **First request**: Server responds with content + ETag header (a fingerprint of the data)
2. **Subsequent requests**: Browser sends `If-None-Match` header with the ETag
3. **Server checks**: If content unchanged, responds with `304 Not Modified` (no body)
4. **Browser uses cache**: Displays cached content without re-downloading

In Rails, `fresh_when` computes an ETag from your objects and halts rendering if the browser's cache is still valid:

```ruby
def show
  fresh_when etag: @card  # Uses @card.cache_key_with_version
end
```

For multiple objects, pass an array—Rails combines them into a single ETag:

```ruby
def show
  @tags = Current.account.tags.alphabetically
  @boards = Current.user.boards.ordered_by_recently_accessed
  
  fresh_when etag: [@tags, @boards]
end
```

The ETag is computed from each object's `cache_key_with_version` (which includes `updated_at`), so any change to any object invalidates the cache.

### Don't HTTP Cache Forms

CSRF tokens get stale → 422 errors on submit ([#1607](https://github.com/basecamp/fizzy/pull/1607))

Remove `fresh_when` from pages with forms.

### Public Caching

- Safe for read-only public pages
- 30 seconds is reasonable ([#1377](https://github.com/basecamp/fizzy/pull/1377))
- Use concern to DRY up cache headers

## Fragment Caching

### Basic Pattern

```ruby
# Bad - same cache for different contexts
cache card

# Good - includes rendering context
cache [card, previewing_card?]
cache [card, Current.user.id]  # if user-specific
```

### Include What Affects Output
- Timezone affects rendered times
- User ID affects personalized content
- Filter state affects what's shown

### Touch Chains for Dependencies ([#566](https://github.com/basecamp/fizzy/pull/566))

```ruby
class Workflow::Stage < ApplicationRecord
  belongs_to :workflow, touch: true
end
```

Changes to children automatically update parent timestamps:

```ruby
# View - workflow changes when any stage changes
cache [card, card.collection.workflow]
```

### Domain Models for Cache Keys ([#1132](https://github.com/basecamp/fizzy/pull/1132))

For complex views, create dedicated cache key objects:

```ruby
class Cards::Columns
  def cache_key
    ActiveSupport::Cache.expand_cache_key([
      considering, on_deck, doing, closed,
      Workflow.all, user_filtering
    ])
  end
end
```

## Lazy Loading with React

Expensive components can slow down page loads. Use React's lazy loading for client-side code splitting, and Inertia's partial reloads for server-side deferred loading.

### Component-Level Code Splitting

```tsx
import { lazy, Suspense } from 'react'
import { Skeleton } from '@/components/ui/skeleton'

// Lazy load expensive components
const HeavyChart = lazy(() => import('./components/HeavyChart'))
const AdvancedFilters = lazy(() => import('./components/AdvancedFilters'))

function Dashboard({ stats }: Props) {
  return (
    <div>
      <StatsCards stats={stats} />

      <Suspense fallback={<Skeleton className="h-64" />}>
        <HeavyChart data={stats.chartData} />
      </Suspense>
    </div>
  )
}
```

### Inertia Partial Reloads

For server-side deferred loading, use Inertia's partial reload feature:

```tsx
import { router } from '@inertiajs/react'

// Only reload specific props
function loadMenuData() {
  router.reload({
    only: ['filters', 'boards', 'tags', 'users']
  })
}

// In component
<Dialog onOpenChange={(open) => open && loadMenuData()}>
  {menuData ? (
    <MenuContent data={menuData} />
  ) : (
    <MenuSkeleton />
  )}
</Dialog>
```

### Intersection Observer for Below-Fold Content

```tsx
import { useEffect, useRef, useState, ReactNode } from 'react'
import { Skeleton } from '@/components/ui/skeleton'

function LazySection({ children }: { children: ReactNode }) {
  const [isVisible, setIsVisible] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!ref.current) return

    const observer = new IntersectionObserver(
      ([entry]) => entry.isIntersecting && setIsVisible(true),
      { threshold: 0.1 }
    )

    observer.observe(ref.current)
    return () => observer.disconnect()
  }, [])

  return (
    <div ref={ref}>
      {isVisible ? children : <Skeleton className="h-48" />}
    </div>
  )
}
```

**Key points:**
- `React.lazy()` splits code at component boundaries
- `Suspense` shows fallback while loading
- Inertia `only` option reloads specific props without full page refresh
- IntersectionObserver defers rendering until element is visible

## User-Specific Content in React Components

With React, user-specific content is naturally handled through props. The `auth` object is shared via `inertia_share`:

```tsx
import { usePage } from '@inertiajs/react'
import { PageProps } from '@/types'

function CardActions({ card }: { card: Card }) {
  const { auth } = usePage<PageProps>().props

  const isOwner = auth.user?.id === card.creator_id
  const canEdit = isOwner || auth.user?.role === 'admin'

  return (
    <div className="flex gap-2">
      {canEdit && (
        <Button variant="ghost" size="sm">
          Edit
        </Button>
      )}
      {isOwner && (
        <Button variant="ghost" size="sm" className="text-destructive">
          Delete
        </Button>
      )}
    </div>
  )
}
```

**Common patterns:**
- "You commented..." indicators → compare `auth.user.id` to creator
- Delete/edit buttons → conditional rendering based on ownership
- "New" badges → compare timestamps to `auth.user.last_seen_at`

## Partial Reloads for Dynamic Sections

When part of a page needs frequent updates, use Inertia's partial reloads instead of full page refreshes:

```tsx
import { router, usePage } from '@inertiajs/react'
import { useState, useEffect } from 'react'

function CardWithAssignment({ card, assignment }: Props) {
  const refreshAssignment = () => {
    router.reload({ only: ['assignment'] })
  }

  return (
    <article className="card">
      <h2>{card.title}</h2>

      {/* Assignment can update independently */}
      <AssignmentDropdown
        assignment={assignment}
        onUpdate={refreshAssignment}
      />
    </article>
  )
}
```

The controller marks expensive props as lazy:

```ruby
def show
  render inertia: "Cards/Show", props: {
    card: serialize_card(@card),
    # Lazy props are only loaded on partial reloads
    assignment: -> { serialize_assignment(@card.assignment) }
  }
end
```

Assignment updates don't require re-rendering the entire card.
