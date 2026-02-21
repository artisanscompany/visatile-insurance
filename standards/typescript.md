# TypeScript Patterns

> Type-safe React development with Rails backend.

---

## Type Definitions Location

All shared TypeScript types are defined in a single file:

```
app/views/types/index.ts
```

This file contains:
- Shared props types (`PageProps`, `DashboardPageProps`)
- Model types (`User`, `Account`, `Workspace`, etc.)
- API response types
- Form data types

---

## Core Shared Types

### Authentication & Session

```typescript
// Flash messages from Rails
export type FlashData = {
  notice?: string
  alert?: string
}

// Current user info
export type User = {
  id: string
  name: string
  email: string
}

// Current account info
export type Account = {
  id: string
  name: string
  slug: string
  type: 'IndividualAccount' | 'TeamAccount'
}

// Auth context shared with all pages
export type AuthData = {
  user: User | null
  account: Account | null
  impersonating: boolean
}
```

### Page Props

```typescript
// Shared props available on every Inertia page
export type SharedProps = {
  auth: AuthData
  flash: FlashData
}

// Base page props - extend this for specific pages
export type PageProps<T = Record<string, unknown>> = SharedProps & T
```

### Dashboard Props

For account-scoped authenticated pages:

```typescript
// Sidebar permission flags from SidebarAuthorization concern
export type SidebarPermissions = {
  can_invite_members: boolean
  can_remove_members: boolean
  can_edit_member_privileges: boolean
  can_create_privilege_templates: boolean
  can_manage_account_settings: boolean
  can_manage_payment_settings: boolean
}

// User privileges for the current account
export type UserPrivileges = {
  role?: 'member' | 'admin' | 'owner'
}

// Extended page props for dashboard pages
export type DashboardPageProps<T = Record<string, unknown>> = PageProps<T> & {
  account: DashboardAccount
  sidebar: SidebarPermissions
  privileges: UserPrivileges
}
```

---

## Model Types

### Defining Model Types

Map Rails models to TypeScript types. Only include fields that are serialized to the frontend:

```typescript
// Workspace types
export type Workspace = {
  id: string
  name: string
  slug: string
  description?: string
  city?: string
  country?: string
  photo_url?: string
  listed: boolean
  active: boolean
}

// Workstation types
export type Workstation = {
  id: string
  name: string
  workstation_type: string
  description?: string
  capacity: number
  quantity: number
  hourly_rate_cents?: number
  daily_rate_cents?: number
  weekly_rate_cents?: number
  monthly_rate_cents?: number
  currency: string
  bookable: boolean
  photos: string[]
}
```

### Enum-like Types

Use union types for Rails enums:

```typescript
export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'declined' | 'completed'
export type BookingPeriodType = 'hourly' | 'daily' | 'weekly' | 'monthly'
export type AccountType = 'IndividualAccount' | 'TeamAccount'
export type UserRole = 'member' | 'admin' | 'owner'
```

### Nested Types

For complex serialized data:

```typescript
export type BookingDetail = BookingSummary & {
  workstation: {
    id: string
    name: string
    workstation_type: string
    capacity: number
    photo_url?: string
  }
  workspace: {
    id: string
    name: string
    slug: string
    location: string
    phone?: string
    email?: string
  }
  booked_by: {
    id: string
    name: string
    email: string
  }
  sessions: BookingSession[]
}
```

---

## Page-Specific Props

### Pattern: Define Props Interface

Each page should define its own props interface:

```typescript
// app/views/pages/Discovery/Show.tsx
import { PageProps, WorkstationDetail, WorkspaceForWorkstation, BookingOption } from '@/types'

interface Props {
  workstation: WorkstationDetail
  workspace: WorkspaceForWorkstation
  booking_options: BookingOption[]
}

export default function Show({ workstation, workspace, booking_options }: Props) {
  const { auth } = usePage<PageProps>().props
  // ...
}
```

### Pattern: Dashboard Page Props

```typescript
// app/views/pages/Account/Dashboard/Show.tsx
import { DashboardPageProps, DashboardStats, DashboardActivity } from '@/types'

interface Props {
  stats: DashboardStats
  upcoming_activities: DashboardActivity[]
}

export default function Show({ stats, upcoming_activities }: Props) {
  const { account, sidebar, privileges } = usePage<DashboardPageProps>().props
  // ...
}
```

---

## Pagination Types

For Pagy-based pagination:

```typescript
export type PaginationMeta = {
  page: number
  pages: number
  count: number
  items: number
  from: number
  to: number
  prev: number | null
  next: number | null
}

// Usage in page props
interface Props {
  workstations: Workstation[]
  pagination: PaginationMeta
}
```

---

## Filter Types

For search/filter interfaces:

```typescript
export type DiscoveryFilters = {
  query?: string
  country_id?: string
  state_id?: string
  city_id?: string
  workstation_type?: string
  min_capacity?: number
  max_hourly_rate?: number
  max_daily_rate?: number
  available_on?: string
  amenity_ids: string[]
  sort_by: string
}

export type SelectOption = {
  id?: string
  value?: string
  name?: string
  label?: string
}

export type DiscoveryOptions = {
  countries: SelectOption[]
  states: SelectOption[]
  cities: SelectOption[]
  workstation_types: SelectOption[]
  sort_options: SelectOption[]
}
```

---

## Component Props

### Layout Props

```typescript
interface PublicLayoutProps {
  children: ReactNode
  fullWidth?: boolean
}

interface DashboardLayoutProps {
  children: ReactNode
  title: string
}
```

### UI Component Props

```typescript
interface BookingCardProps {
  booking: BookingSummary
  onCancel?: (id: string) => void
}

interface PhotoGalleryProps {
  photos: WorkstationPhoto[]
  workstationType: string
}
```

---

## Form Types

### useForm with Types

```typescript
type BookingFormData = {
  workstation_id: string
  starts_at: string
  ends_at: string
  notes: string
}

const { data, setData, post, errors } = useForm<BookingFormData>({
  workstation_id: '',
  starts_at: '',
  ends_at: '',
  notes: '',
})
```

### Error Types

```typescript
// Inertia form errors are Record<string, string>
type FormErrors = Partial<Record<keyof BookingFormData, string>>
```

---

## Utility Types

### Optional Fields

Use `?` for fields that may be undefined:

```typescript
export type Workspace = {
  id: string           // Required
  name: string         // Required
  description?: string // Optional
  photo_url?: string   // Optional
}
```

### Nullable vs Optional

```typescript
// Optional: field may not exist
description?: string

// Nullable: field exists but may be null
user: User | null
```

### Extending Types

```typescript
// Base type
export type BlogPost = {
  id: string
  title: string
  slug: string
  excerpt?: string
  author: BlogAuthor
}

// Extended type with additional fields
export type BlogPostDetail = BlogPost & {
  body_html: string
}
```

---

## Path Aliases

Configure TypeScript path aliases in `tsconfig.app.json`:

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./app/views/*"],
      "~/*": ["./app/views/*"]
    }
  }
}
```

Usage:

```typescript
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { PageProps, User } from '@/types'
```

---

## Best Practices

### Do

- **Define all types in `types/index.ts`** - Single source of truth
- **Use union types for enums** - `'pending' | 'confirmed'`
- **Mark optional fields** - Use `?` for nullable fields
- **Extend base types** - `DashboardPageProps<Props>`
- **Type all props** - Every component should have typed props

### Don't

- **Don't use `any`** - Be explicit about types
- **Don't duplicate types** - Import from `@/types`
- **Don't over-type** - Only type what's used
- **Don't forget null checks** - `auth.user` can be null

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Model types | PascalCase | `Workspace`, `Booking` |
| Page props | `{PageName}Props` or inline `Props` | `interface Props` |
| Enum-like | `{Model}{Field}` | `BookingStatus`, `UserRole` |
| API responses | `{Model}Detail`, `{Model}Summary` | `BookingDetail` |
| Form data | `{Action}FormData` | `BookingFormData` |

---

## Related Documentation

- [Inertia.js + React](inertia-react.md) - Page components and navigation
- [Views & Frontend](views.md) - Complete frontend architecture
