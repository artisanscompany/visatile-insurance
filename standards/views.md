# Views & Frontend Architecture

> Inertia.js + React with shadcn/ui components and Tailwind CSS.

---

## Frontend Strategy

The application uses **Inertia.js + React** for all interactive pages:

- **React components** for rich interactivity
- **shadcn/ui** for consistent, accessible UI components
- **Tailwind CSS** for utility-first styling
- **TypeScript** for type-safe development
- **Server-side routing** - Rails controllers render Inertia responses

```
Rails Controller → render inertia: "Page/Path" → React Component
```

---

## Page Structure

### Directory Layout

```
app/views/
├── pages/                    # Inertia page components
│   ├── Discovery/
│   │   ├── Index.tsx
│   │   ├── Show.tsx
│   │   └── components/       # Page-specific components
│   ├── Account/
│   │   ├── Dashboard/
│   │   ├── Bookings/
│   │   └── Workspaces/
│   └── Public/
│       └── Index.tsx
├── components/
│   ├── ui/                   # shadcn/ui components
│   └── layout/               # Layout components
├── types/
│   └── index.ts              # TypeScript definitions
└── lib/
    └── utils.ts              # Utilities (cn function)
```

### Page Component Pattern

```tsx
import { Head, usePage } from '@inertiajs/react'
import { PageProps } from '@/types'
import { PublicLayout } from '@/components/layout/PublicLayout'

interface Props {
  workspace: Workspace
  workstations: Workstation[]
}

export default function Show({ workspace, workstations }: Props) {
  const { auth } = usePage<PageProps>().props

  return (
    <PublicLayout>
      <Head title={workspace.name} />
      {/* Page content */}
    </PublicLayout>
  )
}
```

---

## shadcn/ui Components

### Available Components

Located in `app/views/components/ui/`:

| Component | Description |
|-----------|-------------|
| `button` | Buttons with variants (default, outline, ghost, destructive) |
| `card` | Card containers with Header, Content, Footer |
| `badge` | Status badges and tags |
| `input` | Text input fields |
| `label` | Form labels |
| `select` | Dropdown select menus |
| `checkbox` | Checkbox inputs |
| `tabs` | Tabbed interfaces |
| `accordion` | Collapsible sections |
| `separator` | Divider lines |
| `breadcrumb` | Navigation breadcrumbs |
| `carousel` | Image carousels |

### Import Pattern

```tsx
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
```

### Component Variants

Components use Class Variance Authority (CVA) for variants:

```tsx
// Button variants
<Button variant="default">Primary Action</Button>
<Button variant="outline">Secondary Action</Button>
<Button variant="ghost">Tertiary Action</Button>
<Button variant="destructive">Delete</Button>

// Badge variants
<Badge variant="default">Active</Badge>
<Badge variant="outline">Pending</Badge>
<Badge variant="secondary">Draft</Badge>
```

### Card Composition

```tsx
<Card>
  <CardHeader>
    <CardTitle>Booking Details</CardTitle>
  </CardHeader>
  <CardContent>
    <p>Content goes here</p>
  </CardContent>
</Card>
```

---

## The `cn()` Utility

Combine Tailwind classes with conditional logic:

```tsx
import { cn } from '@/lib/utils'

// Basic usage
<div className={cn('p-4 rounded-lg', 'bg-white')}>

// Conditional classes
<div className={cn(
  'p-4 rounded-lg',
  isActive && 'bg-primary text-primary-foreground',
  isDisabled && 'opacity-50 cursor-not-allowed'
)}>

// Override with custom classes
<Button className={cn('w-full', className)}>
```

Implementation:

```typescript
// app/views/lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

---

## Layout Components

### Public Layout

For public-facing pages:

```tsx
import { PublicLayout } from '@/components/layout/PublicLayout'

export default function Show({ workspace }: Props) {
  return (
    <PublicLayout>
      {/* Content */}
    </PublicLayout>
  )
}

// Full-width variant
<PublicLayout fullWidth>
  {/* Hero sections, carousels */}
</PublicLayout>
```

### Dashboard Layout

For authenticated account pages:

```tsx
import { DashboardLayout } from '@/components/layout/DashboardLayout'

export default function Show({ stats }: Props) {
  return (
    <DashboardLayout title="Dashboard">
      {/* Content */}
    </DashboardLayout>
  )
}
```

---

## Icons

Using Remix Icons via `@remixicon/react`:

```tsx
import { RiMapPinLine, RiTeamLine, RiCheckboxCircleLine } from '@remixicon/react'

<Badge variant="outline">
  <RiTeamLine className="w-4 h-4 mr-1" />
  {capacity} people
</Badge>
```

Or inline with Remix Icon classes:

```tsx
<i className="ri-map-pin-line text-muted-foreground" />
```

---

## Flash Messages

Flash messages are passed via `inertia_share` and displayed in layouts:

```tsx
const { flash } = usePage<PageProps>().props

{flash.notice && (
  <div className="p-4 rounded-lg bg-primary/10 border border-primary/20 text-primary">
    {flash.notice}
  </div>
)}

{flash.alert && (
  <div className="p-4 rounded-lg bg-destructive/10 border border-destructive/20 text-destructive">
    {flash.alert}
  </div>
)}
```

---

## Navigation

### Inertia Link

```tsx
import { Link } from '@inertiajs/react'

<Link href="/discover">Discover Workspaces</Link>

// With Button component
<Button asChild variant="outline">
  <Link href="/booking/new">Book Now</Link>
</Button>
```

### Breadcrumbs

```tsx
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/components/ui/breadcrumb'

<Breadcrumb>
  <BreadcrumbList>
    <BreadcrumbItem>
      <BreadcrumbLink asChild>
        <Link href="/">Home</Link>
      </BreadcrumbLink>
    </BreadcrumbItem>
    <BreadcrumbSeparator />
    <BreadcrumbItem>
      <BreadcrumbPage>{workspace.name}</BreadcrumbPage>
    </BreadcrumbItem>
  </BreadcrumbList>
</Breadcrumb>
```

---

## Forms

### Basic Form with useForm

```tsx
import { useForm } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

function BookingForm({ workstationId }: { workstationId: string }) {
  const { data, setData, post, processing, errors } = useForm({
    workstation_id: workstationId,
    notes: '',
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post('/bookings')
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <Label htmlFor="notes">Notes</Label>
        <Input
          id="notes"
          value={data.notes}
          onChange={e => setData('notes', e.target.value)}
        />
        {errors.notes && (
          <p className="text-sm text-destructive mt-1">{errors.notes}</p>
        )}
      </div>

      <Button type="submit" disabled={processing}>
        {processing ? 'Booking...' : 'Book Now'}
      </Button>
    </form>
  )
}
```

---

## Responsive Design

Mobile-first with Tailwind breakpoints:

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Responsive grid */}
</div>

<div className="hidden md:flex">
  {/* Desktop only */}
</div>

<div className="md:hidden">
  {/* Mobile only */}
</div>
```

---

## Data Display Patterns

### Lists with Cards

```tsx
<div className="grid gap-4">
  {workstations.map((workstation) => (
    <Card key={workstation.id}>
      <CardContent className="p-4">
        <h3 className="font-semibold">{workstation.name}</h3>
        <p className="text-sm text-muted-foreground">{workstation.description}</p>
      </CardContent>
    </Card>
  ))}
</div>
```

### Empty States

```tsx
{workstations.length === 0 ? (
  <div className="text-center py-12">
    <p className="text-muted-foreground">No workstations found</p>
    <Button asChild variant="outline" className="mt-4">
      <Link href="/discover">Browse All</Link>
    </Button>
  </div>
) : (
  <WorkstationGrid workstations={workstations} />
)}
```

### Loading States

```tsx
<Button disabled={processing}>
  {processing ? (
    <>
      <RiLoader4Line className="w-4 h-4 mr-2 animate-spin" />
      Loading...
    </>
  ) : (
    'Submit'
  )}
</Button>
```

---

## Page Titles & Meta

```tsx
import { Head } from '@inertiajs/react'

<Head title={`${workspace.name} - Workingstations`} />

// With meta tags
<Head>
  <title>{workspace.name}</title>
  <meta name="description" content={workspace.description} />
</Head>
```

---

## ERB Templates (Non-Interactive Content)

ERB templates are used for content that doesn't require React:

- **Email templates** (`app/views/*_mailer/`)
- **PDF generation** (Prawn, WickedPDF)
- **Plain text exports**

For all user-facing web pages, use Inertia + React.

---

## Best Practices

### Do

- **Use shadcn/ui components** - Consistent, accessible UI
- **Type all props** - TypeScript for everything
- **Use layouts** - Wrap pages in `PublicLayout` or `DashboardLayout`
- **Mobile-first** - Start with mobile, add breakpoints
- **Semantic colors** - `text-muted-foreground`, not `text-gray-500`

### Don't

- **Don't inline long class strings** - Extract to components
- **Don't skip error states** - Always handle `errors` from forms
- **Don't forget loading states** - Use `processing` from useForm
- **Don't hardcode colors** - Use theme variables

---

## Related Documentation

- [Inertia.js + React](inertia-react.md) - Controllers, navigation, forms
- [TypeScript Patterns](typescript.md) - Type definitions
- [CSS & Styling](css.md) - Tailwind configuration, theming
- [Controllers](controllers.md) - Inertia controller patterns
