# CR4FTS Design System

Design standards for the CR4FTS website. Based on the Visatile Style Bible — a Brian Lovin-inspired system built for clarity, restraint, and craft.

---

## Typeface

**Instrument Sans** — loaded via Google Fonts at weights 400, 500, 600, 700.

```css
font-family: "Instrument Sans", system-ui, sans-serif;
```

## Typography Scale

| Element             | Size                    | Weight     | Class                                           |
|---------------------|-------------------------|------------|-------------------------------------------------|
| Page title          | text-4xl md:text-5xl    | bold (700) | `text-4xl md:text-5xl font-bold`                |
| Section heading     | text-3xl md:text-4xl    | bold (700) | `text-3xl md:text-4xl font-bold`                |
| Card title          | text-lg md:text-xl      | semibold   | `text-lg md:text-xl font-semibold`              |
| Body                | text-base md:text-lg    | normal     | `text-base md:text-lg`                          |
| Small / caption     | text-sm                 | normal     | `text-sm text-muted-foreground`                 |
| Label               | text-xs                 | semibold   | `text-xs font-semibold uppercase tracking-wider`|

All headings use `letter-spacing: -0.01em` via inline style.

## Color System (OKLCH)

All colors are defined as Tailwind CSS v4 theme tokens in `application.css`.

### Brand
| Token              | Value                    | Usage                     |
|--------------------|--------------------------|---------------------------|
| `primary`          | `oklch(0.22 0.04 260)`  | Navy blue — buttons, links, accents |
| `primary-hover`    | `oklch(0.28 0.04 260)`  | Hover state for primary   |

### Neutrals
| Token              | Value                    | Usage                     |
|--------------------|--------------------------|---------------------------|
| `background`       | `oklch(0.985 0.002 250)` | Page background           |
| `foreground`       | `oklch(0.145 0.025 250)` | Primary text, dark fills  |
| `muted`            | `oklch(0.96 0.01 250)`   | Subtle backgrounds        |
| `muted-foreground` | `oklch(0.45 0.02 250)`   | Secondary text, captions  |
| `border`           | `oklch(0.9 0.01 250)`    | Card borders, dividers    |
| `card`             | `#FFFFFF`                | Card backgrounds          |

### Semantic
| Token          | Value                    | Usage              |
|----------------|--------------------------|---------------------|
| `destructive`  | `oklch(0.55 0.22 25)`   | Errors, danger      |
| `success`      | `oklch(0.6 0.18 145)`   | Success states      |
| `warning`      | `oklch(0.85 0.18 90)`   | Warnings            |
| `info`         | `oklch(0.55 0.15 195)`  | Info messages       |

## Buttons

Built on shadcn/ui `Button` with `buttonVariants` for anchor elements.

| Variant     | Style                                        |
|-------------|----------------------------------------------|
| `default`   | `bg-primary text-white hover:bg-primary-hover` — navy blue filled |
| `secondary` | `bg-muted text-foreground hover:bg-muted/80` |
| `outline`   | `border border-border bg-card hover:bg-muted` |
| `ghost`     | `hover:bg-muted text-foreground`              |
| `link`      | `underline-offset-4 hover:underline`          |
| `destructive` | `bg-destructive text-white`                 |

All buttons include:
- `rounded-lg` border radius
- `font-semibold` weight
- `active:scale-[0.97]` press feedback
- `duration-200` transition
- `focus-visible:ring-2 focus-visible:ring-primary` focus ring

**One primary action per screen area.** Use `default` variant sparingly — one per section. Secondary actions use `ghost` or `outline`.

## Cards

```
rounded-xl shadow-sm border border-border bg-card
```

- Hover: `hover:-translate-y-1 hover:shadow-md` (interactive cards only)
- Transition: `duration-200`
- Paper-card aesthetic with subtle `rotate-1` / `-rotate-1` transforms where appropriate

## Spacing

- Section padding: `py-16 md:py-24`
- Section content gap: `mb-12 md:mb-16` between heading and content
- Container: `max-w-6xl mx-auto px-4 sm:px-6 lg:px-8`
- Narrow container (forms, text): `max-w-lg mx-auto` or `max-w-4xl mx-auto`

## Motion

- Standard transition: `duration-200`
- Entry animation: `fadeInUp` at `0.4s` with `cubic-bezier(0.16, 1, 0.3, 1)`
- Staggered children: increment delay by `0.1s`
- Respect `prefers-reduced-motion`: animations and transitions disabled

```css
@media (prefers-reduced-motion: reduce) {
  * {
    transition-duration: 0ms !important;
    animation-duration: 0ms !important;
  }
}
```

## Form Inputs

```
w-full px-4 py-3 rounded-lg border border-border bg-background text-foreground
placeholder:text-muted-foreground/50
focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-1
transition-all duration-200
```

Labels: `text-xs font-semibold uppercase tracking-wider text-muted-foreground`

## Focus & Accessibility

- All interactive elements: `focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2`
- Global focus ring defined in CSS: `outline: 2px solid var(--color-primary); outline-offset: 2px`
- Reduced motion respected via media query
- Semantic color contrast maintained at WCAG AA minimum

## Content Rules

- **Sentence case** for all UI text (headings, buttons, labels)
- **No periods** on single-line UI text (headings, button labels, captions)
- Periods only in multi-sentence body copy
- Use `&apos;` for apostrophes in JSX

## File Structure

```
app/frontend/
  styles/application.css          # Tailwind v4 theme + animations
  components/ui/button.tsx        # shadcn Button (primary source of truth)
  components/shared/              # Header, Footer, FlashMessages
  components/home/                # Homepage sections
  lib/utils.ts                    # cn() utility
```

## Key Patterns

### Anchor as Button
Use `buttonVariants` from shadcn for anchor elements that look like buttons:
```tsx
import { buttonVariants } from "@/components/ui/button"

<a href="/path" className={buttonVariants({ variant: "default", size: "lg" })}>
  Label
</a>
```

### Section Heading Pattern
```tsx
<div className="text-center mb-12 md:mb-16">
  <h2
    className="text-4xl md:text-5xl font-bold leading-tight mb-3 text-foreground"
    style={{ letterSpacing: "-0.01em" }}
  >
    Section title
  </h2>
  <p className="text-lg md:text-xl leading-relaxed text-muted-foreground max-w-2xl mx-auto">
    Supporting line without a period
  </p>
</div>
```

### Dark Inverted Section
Use `bg-foreground` for dark sections with white text:
```tsx
<div className="bg-foreground">
  <h2 className="text-white">...</h2>
  <p className="text-white/80">...</p>
</div>
```
