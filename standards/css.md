# CSS & Styling

> Tailwind CSS with shadcn/ui theming and CSS custom properties.

---

## Stack Overview

- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Component library built on Radix UI + Tailwind
- **CSS Custom Properties** - Theme variables for colors, spacing
- **Class Variance Authority (CVA)** - Component variant management
- **tailwind-merge** - Intelligent class merging

---

## Tailwind Configuration

### Entry Point

```css
/* app/views/entrypoints/application.css */
@import 'tailwindcss';
@import 'remixicon/fonts/remixicon.css';
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@plugin '@tailwindcss/typography';
@plugin '@tailwindcss/forms';
```

### Theme Configuration

```javascript
// config/tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#1a1a1a',
          light: '#f5f5f5',
          primary: '#059669',    // emerald-600
          secondary: '#10b981',  // emerald-500
        },
      },
      fontFamily: {
        sans: ['Outfit', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

---

## Theming with CSS Variables

### shadcn/ui Theme System

Theme colors are defined as CSS custom properties:

```css
/* Light Mode (Emerald Theme) */
:root {
  --radius: 0.65rem;
  --background: var(--color-white);
  --foreground: var(--color-neutral-950);
  --card: var(--color-white);
  --card-foreground: var(--color-neutral-950);
  --primary: var(--color-emerald-600);
  --primary-foreground: var(--color-emerald-50);
  --secondary: var(--color-neutral-100);
  --secondary-foreground: var(--color-neutral-900);
  --muted: var(--color-neutral-100);
  --muted-foreground: var(--color-neutral-500);
  --destructive: var(--color-red-600);
  --border: var(--color-neutral-200);
  --input: var(--color-neutral-200);
  --ring: var(--color-emerald-600);
}

/* Dark Mode */
.dark {
  --background: var(--color-neutral-950);
  --foreground: var(--color-neutral-50);
  --card: var(--color-neutral-900);
  --card-foreground: var(--color-neutral-50);
  --primary: var(--color-emerald-500);
  --primary-foreground: var(--color-emerald-950);
  --muted: var(--color-neutral-800);
  --muted-foreground: var(--color-neutral-400);
  --destructive: var(--color-red-500);
  --border: var(--color-neutral-800);
}
```

### Semantic Color Usage

Always use semantic color names, not raw Tailwind colors:

```tsx
// GOOD - Semantic colors
<p className="text-muted-foreground">Secondary text</p>
<div className="bg-card border-border">Card</div>
<span className="text-destructive">Error message</span>

// BAD - Raw colors (hard to theme)
<p className="text-gray-500">Secondary text</p>
<div className="bg-white border-gray-200">Card</div>
<span className="text-red-600">Error message</span>
```

### Available Semantic Colors

| Variable | Usage |
|----------|-------|
| `background` | Page background |
| `foreground` | Primary text |
| `card` / `card-foreground` | Card surfaces |
| `primary` / `primary-foreground` | Primary buttons, links |
| `secondary` / `secondary-foreground` | Secondary actions |
| `muted` / `muted-foreground` | Disabled states, subtle text |
| `destructive` | Error states, delete actions |
| `border` | Borders and dividers |
| `input` | Form input borders |
| `ring` | Focus rings |

---

## The `cn()` Utility

Combines `clsx` and `tailwind-merge` for intelligent class merging:

```typescript
// app/views/lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### Usage

```tsx
import { cn } from '@/lib/utils'

// Basic merging
<div className={cn('p-4 rounded-lg', 'bg-card')}>

// Conditional classes
<div className={cn(
  'p-4 rounded-lg',
  isActive && 'bg-primary text-primary-foreground',
  isDisabled && 'opacity-50 cursor-not-allowed'
)}>

// Props override base classes
function Card({ className, ...props }) {
  return (
    <div className={cn('rounded-lg border bg-card', className)} {...props} />
  )
}
```

---

## Class Variance Authority (CVA)

CVA manages component variants in shadcn/ui:

```tsx
import { cva, type VariantProps } from 'class-variance-authority'

const buttonVariants = cva(
  // Base classes
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
)

// Usage
<Button variant="outline" size="lg">Click me</Button>
```

---

## Responsive Design

Mobile-first approach with Tailwind breakpoints:

```tsx
// Mobile-first grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// Hide on mobile
<div className="hidden md:flex">Desktop only</div>

// Show only on mobile
<div className="md:hidden">Mobile only</div>

// Responsive spacing
<div className="p-4 md:p-6 lg:p-8">

// Responsive text
<h1 className="text-2xl md:text-3xl lg:text-4xl">
```

### Breakpoints

| Prefix | Min Width |
|--------|-----------|
| `sm:` | 640px |
| `md:` | 768px |
| `lg:` | 1024px |
| `xl:` | 1280px |
| `2xl:` | 1536px |

---

## Common Patterns

### Card with Hover State

```tsx
<div className="rounded-lg border bg-card p-4 hover:shadow-md transition-shadow">
  <h3 className="font-semibold text-foreground">Title</h3>
  <p className="text-sm text-muted-foreground">Description</p>
</div>
```

### Form Field

```tsx
<div className="space-y-2">
  <Label htmlFor="email">Email</Label>
  <Input id="email" type="email" placeholder="you@example.com" />
  {error && <p className="text-sm text-destructive">{error}</p>}
</div>
```

### Button Group

```tsx
<div className="flex items-center gap-2">
  <Button variant="default">Primary</Button>
  <Button variant="outline">Secondary</Button>
  <Button variant="ghost">Tertiary</Button>
</div>
```

### Status Badge

```tsx
<Badge variant={status === 'active' ? 'default' : 'outline'}>
  {status}
</Badge>
```

---

## Icons

Using Remix Icons via `@remixicon/react`:

```tsx
import { RiMapPinLine, RiUserLine, RiCalendarLine } from '@remixicon/react'

<RiMapPinLine className="w-4 h-4 text-muted-foreground" />
```

Or inline with icon classes:

```tsx
<i className="ri-map-pin-line text-muted-foreground" />
```

---

## Border Radius Scale

shadcn/ui uses CSS variables for consistent radius:

```css
--radius-sm: calc(var(--radius) - 4px);
--radius-md: calc(var(--radius) - 2px);
--radius-lg: var(--radius);
--radius-xl: calc(var(--radius) + 4px);
```

```tsx
<div className="rounded-lg">  // Uses --radius-lg
<div className="rounded-md">  // Uses --radius-md
<div className="rounded-sm">  // Uses --radius-sm
```

---

## Best Practices

### Do

- **Use semantic colors** - `text-muted-foreground` not `text-gray-500`
- **Use `cn()` for merging** - Handles conflicts intelligently
- **Mobile-first** - Start with mobile, add breakpoints
- **Use CVA for variants** - Consistent component APIs
- **Consistent spacing** - Use Tailwind spacing scale

### Don't

- **Don't use raw colors** - Hard to theme
- **Don't duplicate class strings** - Extract to components
- **Don't skip focus states** - Accessibility matters
- **Don't fight the framework** - Use Tailwind patterns

---

## File Organization

```
app/views/
├── components/
│   └── ui/                 # shadcn/ui components
│       ├── button.tsx
│       ├── card.tsx
│       └── ...
├── lib/
│   └── utils.ts           # cn() utility
└── entrypoints/
    └── application.css    # Tailwind imports + theme
```

---

## Related Documentation

- [Views & Frontend](views.md) - Component usage in pages
- [Inertia.js + React](inertia-react.md) - Page structure
- [TypeScript Patterns](typescript.md) - Type definitions
