# Inertia.js + React

> Modern React frontend with Rails backend, no client-side routing.

---

## Why Inertia.js

Inertia.js is a protocol and library that connects Rails controllers directly to React components, eliminating the need for:

- JSON APIs
- Client-side routing (react-router, etc.)
- Complex state management (Redux, etc.)
- Separate frontend deployments

**Key benefits:**

- **SPA-like experience** without SPA complexity
- **Server-side routing** with React views
- **Full TypeScript support** for type-safe props
- **Rails conventions** remain intact

```
Rails Controller → render inertia: "Page/Path" → React Component
```

---

## Configuration

### Rails Initializer

```ruby
# config/initializers/inertia_rails.rb
InertiaRails.configure do |config|
  config.version = ViteRuby.digest        # Cache busting via Vite
  config.encrypt_history = true            # Encrypt browser history state
  config.always_include_errors_hash = true # Always include errors in props
  config.use_script_element_for_initial_page = true  # Smaller HTML payload
end
```

### Vite Configuration

```typescript
// vite.config.mts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    RubyPlugin(),
  ],
})
```

### Entry Point

```tsx
// app/views/entrypoints/inertia.tsx
import { createInertiaApp, type ResolvedComponent } from '@inertiajs/react'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

void createInertiaApp({
  resolve: (name) => {
    const pages = import.meta.glob<{default: ResolvedComponent}>('../pages/**/*.tsx', {
      eager: true,
    })
    const page = pages[`../pages/${name}.tsx`]
    if (!page) {
      console.error(`Missing Inertia page component: '${name}.tsx'`)
    }
    return page
  },

  setup({ el, App, props }) {
    createRoot(el).render(
      <StrictMode>
        <App {...props} />
      </StrictMode>
    )
  },

  defaults: {
    future: {
      useScriptElementForInitialPage: true,
      useDataInertiaHeadAttribute: true,
      useDialogForErrorModal: true,
      preserveEqualProps: true,
    },
  },
})
```

---

## Controller Patterns

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

### Account-Scoped Controller

For authenticated dashboard pages:

```ruby
# app/controllers/account_inertia_controller.rb
class AccountInertiaController < InertiaController
  include PrivilegeAuthorization
  include SidebarAuthorization

  before_action :require_authentication
  before_action :set_account
  before_action :set_sidebar_authorization
  before_action :require_account_membership

  # Share additional account-specific data
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
      workspace: serialize_workspace_for_workstation(@workstation.workspace),
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
      # ... more fields
    }
  end
end
```

### Props Serialization Guidelines

1. **Use plain Ruby hashes** - No serializer gems needed
2. **Convert money to floats** - `workstation.hourly_rate_cents / 100.0`
3. **Use `url_for` for attachments** - `url_for(workstation.photos.first)`
4. **Flatten nested data** - React prefers flat structures
5. **Include only needed fields** - Don't expose entire models

---

## Page Components

### Directory Structure

```
app/views/
├── entrypoints/
│   └── inertia.tsx           # Vite entry point
├── pages/
│   ├── Discovery/
│   │   ├── Index.tsx           # List page
│   │   ├── Show.tsx            # Detail page
│   │   └── components/         # Page-specific components
│   │       ├── PhotoGallery.tsx
│   │       └── BookingCard.tsx
│   ├── Account/
│   │   ├── Dashboard/
│   │   │   └── Show.tsx
│   │   ├── Bookings/
│   │   │   ├── Index.tsx
│   │   │   └── Show.tsx
│   │   └── Workspaces/
│   │       └── Index.tsx
│   ├── Sessions/
│   │   └── New.tsx
│   └── Public/
│       └── Index.tsx           # Homepage
├── components/
│   ├── ui/                     # shadcn/ui components
│   └── layout/                 # Layout components
├── types/
│   └── index.ts                # TypeScript type definitions
└── lib/
    └── utils.ts                # Utility functions (cn, etc.)
```

### Rails Resource Alignment

Page directories mirror Rails resource conventions:

| Rails Pattern | React Pattern | Example |
|---------------|---------------|---------|
| `resources :bookings` | `Bookings/` directory | `pages/Account/Bookings/` |
| `index` action | `Index.tsx` | List page with grid/table |
| `show` action | `Show.tsx` | Detail page |
| `new` action | `New.tsx` | Creation form |
| `edit` action | `Edit.tsx` | Edit form |
| Nested resources | Nested directories | `Account/Bookings/Hourly/New.tsx` |
| Controller partials | `components/` subdirectory | `Bookings/components/BookingCard.tsx` |

### Naming Conventions

**Pages (route-level components):**
- `Index.tsx` - List/collection pages
- `Show.tsx` - Detail/single resource pages
- `New.tsx` - Creation forms
- `Edit.tsx` - Edit forms

**Components (reusable within pages):**
- `*Card.tsx` - Card display components (`BookingCard.tsx`)
- `*Grid.tsx`, `*List.tsx` - Collection displays
- `*Form.tsx` - Form components
- `*Picker.tsx`, `*Selector.tsx` - Selection controls
- `*Summary.tsx`, `*Details.tsx` - Information displays
- `*Filter.tsx`, `*FilterBar.tsx` - Filter controls

### Component Scoping

**Page-specific components** live in `pages/[Resource]/components/`:
```
pages/Account/Bookings/
├── Index.tsx
├── Show.tsx
└── components/
    ├── BookingCard.tsx        # Only used by Bookings pages
    ├── BookingTabs.tsx
    └── BookingSummary.tsx
```

**Shared components** live in `components/`:
```
components/
├── layout/                    # Used across all pages
│   ├── PublicLayout.tsx
│   ├── DashboardLayout.tsx
│   └── Header.tsx
└── ui/                        # shadcn/ui design system
    ├── button.tsx
    ├── card.tsx
    └── ...
```

### Section Components (Non-Route)

For landing pages with multiple sections:
```
pages/Public/
├── Home.tsx                   # Main page component
└── sections/                  # Logical sections (not routes)
    ├── Hero.tsx
    ├── Features.tsx
    └── FAQ.tsx
```

### Delegated Type Support

Period-specific pages for delegated types:
```
pages/Account/Bookings/
├── Index.tsx
├── Show.tsx
├── Hourly/New.tsx             # /bookings/hourly/new
├── Daily/New.tsx              # /bookings/daily/new
├── Weekly/New.tsx             # /bookings/weekly/new
└── Monthly/New.tsx            # /bookings/monthly/new
```

### Page Component Pattern

```tsx
// app/views/pages/Discovery/Show.tsx
import { Head, Link, usePage } from '@inertiajs/react'
import { PageProps, WorkstationDetail, WorkspaceForWorkstation, BookingOption } from '@/types'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'

interface Props {
  workstation: WorkstationDetail
  workspace: WorkspaceForWorkstation
  booking_options: BookingOption[]
}

export default function Show({ workstation, workspace, booking_options }: Props) {
  const { auth } = usePage<PageProps>().props

  return (
    <PublicLayout fullWidth>
      <Head title={`${workstation.name} - ${workspace.name}`} />

      <div className="max-w-4xl mx-auto py-8 px-4">
        <h1 className="text-2xl font-bold">{workstation.name}</h1>
        {/* Component content */}
      </div>
    </PublicLayout>
  )
}
```

### Key Patterns

1. **Default export** - Pages must be default exports
2. **Props interface** - Define typed props for the page
3. **`usePage<PageProps>()`** - Access shared props (auth, flash)
4. **Layout wrapper** - Wrap in `PublicLayout` or `DashboardLayout`
5. **`<Head>`** - Set page title and meta tags

---

## Layout Components

### Public Layout

```tsx
// app/views/components/layout/PublicLayout.tsx
import { ReactNode } from 'react'
import { usePage } from '@inertiajs/react'
import { Header } from './Header'
import { Footer } from './Footer'
import { PageProps } from '@/types'

interface PublicLayoutProps {
  children: ReactNode
  fullWidth?: boolean
}

export function PublicLayout({ children, fullWidth = false }: PublicLayoutProps) {
  const { flash } = usePage<PageProps>().props

  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">
        {(flash.notice || flash.alert) && (
          <div className="max-w-7xl mx-auto px-4">
            {flash.notice && (
              <div className="p-4 rounded-lg bg-primary/10 text-primary">
                {flash.notice}
              </div>
            )}
            {flash.alert && (
              <div className="p-4 rounded-lg bg-destructive/10 text-destructive">
                {flash.alert}
              </div>
            )}
          </div>
        )}
        {children}
      </main>

      <Footer />
    </div>
  )
}
```

### Dashboard Layout

For authenticated account pages with sidebar:

```tsx
// app/views/components/layout/DashboardLayout.tsx
import { ReactNode } from 'react'
import { usePage } from '@inertiajs/react'
import { DashboardSidebar } from './DashboardSidebar'
import { DashboardHeader } from './DashboardHeader'
import { FlashMessages } from './FlashMessages'
import { DashboardPageProps } from '@/types'

interface DashboardLayoutProps {
  children: ReactNode
  title: string
}

export function DashboardLayout({ children, title }: DashboardLayoutProps) {
  const { account, sidebar, privileges, flash } = usePage<DashboardPageProps>().props

  return (
    <div className="min-h-screen">
      <DashboardSidebar account={account} sidebar={sidebar} />

      <div className="md:ml-64">
        <DashboardHeader title={title} />

        <main className="p-6">
          <FlashMessages flash={flash} />
          {children}
        </main>
      </div>
    </div>
  )
}
```

---

## Navigation

### Inertia Link Component

```tsx
import { Link } from '@inertiajs/react'

// Basic link
<Link href="/discover">Discover Workspaces</Link>

// With preserveState (keeps form data, scroll position)
<Link href="/discover?page=2" preserveState>Next Page</Link>

// Replace history (no back button)
<Link href="/dashboard" replace>Dashboard</Link>
```

### Programmatic Navigation

```tsx
import { router } from '@inertiajs/react'

// GET request
router.get('/discover', { query: 'office' })

// With options
router.get(`/${workspace.slug}`, params, {
  preserveState: true,
  preserveScroll: true,
  only: ['workstations', 'pagination', 'filters']  // Partial reload
})

// POST request
router.post('/bookings', { workstation_id: '123' })

// DELETE request
router.delete(`/bookings/${id}`)
```

### Partial Reloads

Only fetch specific props for performance:

```tsx
router.get(window.location.href, filters, {
  preserveState: true,
  preserveScroll: true,
  only: ['workstations', 'pagination']  // Only reload these props
})
```

---

## Form Handling

### Using useForm Hook

```tsx
import { useForm } from '@inertiajs/react'

function BookingForm({ workstationId }: { workstationId: string }) {
  const { data, setData, post, processing, errors } = useForm({
    workstation_id: workstationId,
    starts_at: '',
    ends_at: '',
    notes: '',
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post('/bookings')
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={data.starts_at}
        onChange={e => setData('starts_at', e.target.value)}
      />
      {errors.starts_at && <p className="text-destructive">{errors.starts_at}</p>}

      <Button type="submit" disabled={processing}>
        {processing ? 'Booking...' : 'Book Now'}
      </Button>
    </form>
  )
}
```

### Form with File Upload

```tsx
const { data, setData, post, progress } = useForm({
  name: '',
  photo: null as File | null,
})

function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
  if (e.target.files?.[0]) {
    setData('photo', e.target.files[0])
  }
}

post('/workspaces', {
  forceFormData: true,  // Required for file uploads
})

// Show upload progress
{progress && <progress value={progress.percentage} max="100" />}
```

---

## TypeScript Patterns

### Shared Props Type

```tsx
// app/views/types/index.ts
export type FlashData = {
  notice?: string
  alert?: string
}

export type User = {
  id: string
  name: string
  email: string
}

export type Account = {
  id: string
  name: string
  slug: string
  type: 'IndividualAccount' | 'TeamAccount'
}

export type AuthData = {
  user: User | null
  account: Account | null
  impersonating: boolean
}

export type SharedProps = {
  auth: AuthData
  flash: FlashData
}

// Base type for all pages
export type PageProps<T = Record<string, unknown>> = SharedProps & T
```

### Dashboard Page Props

```tsx
export type SidebarPermissions = {
  can_invite_members: boolean
  can_remove_members: boolean
  can_manage_account_settings: boolean
  // ...
}

export type UserPrivileges = {
  role?: 'member' | 'admin' | 'owner'
}

export type DashboardPageProps<T = Record<string, unknown>> = PageProps<T> & {
  account: DashboardAccount
  sidebar: SidebarPermissions
  privileges: UserPrivileges
}
```

### Using Types in Pages

```tsx
// For public pages
const { auth, flash } = usePage<PageProps>().props

// For dashboard pages
const { auth, account, sidebar, privileges } = usePage<DashboardPageProps>().props
```

---

## Best Practices

### Do

- **Keep controllers thin** - Serialize data, let React handle presentation
- **Type all props** - Use TypeScript interfaces for every page
- **Use layouts** - Wrap pages in `PublicLayout` or `DashboardLayout`
- **Partial reloads** - Use `only` option for performance
- **Share common data** - Use `inertia_share` for auth, flash, account

### Don't

- **Don't expose entire models** - Only serialize needed fields
- **Don't use client-side routing** - Inertia handles navigation
- **Don't fetch data in components** - Pass everything via props
- **Don't use Redux/Zustand** - Inertia + props is enough

---

## Related Documentation

- [TypeScript Patterns](typescript.md) - Type definitions and patterns
- [Views & Frontend](views.md) - Complete frontend architecture
- [Controllers](controllers.md) - Controller patterns including Inertia section
- [shadcn/ui Components](css.md) - Component styling patterns

## External Resources

- [Inertia Rails Official Docs](https://inertia-rails.dev/guide)
- [Inertia.js Shared Data](https://inertia-rails.dev/guide/shared-data)
- [Evil Martians Inertia.js Guide](https://evilmartians.com/chronicles/inertiajs-in-rails-a-new-era-of-effortless-integration)
