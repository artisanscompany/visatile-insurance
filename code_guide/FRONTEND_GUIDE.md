# Frontend Development Guide

> **Views, Helpers, Turbo, Stimulus & CSS** - Frontend patterns from the 37signals Fizzy codebase

This guide covers client-side Rails development. For backend patterns, see [BACKEND_GUIDE.md](./BACKEND_GUIDE.md). For infrastructure, see [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md).

---

## Table of Contents

1. [View Organization](#view-organization)
2. [Helper Patterns](#helper-patterns)
3. [Turbo & Real-time Updates](#turbo--real-time-updates)
4. [Stimulus Controllers](#stimulus-controllers)
5. [CSS Architecture](#css-architecture)
6. [Frontend Checklist](#frontend-checklist)

---

## View Organization

### Partition into Small, Focused Partials

```
app/views/cards/
├── show.html.erb          # Main view (minimal)
├── show/
│   ├── _header.html.erb   # Card header
│   ├── _content.html.erb  # Card content
│   ├── _comments.html.erb # Comments section
│   └── _meta.html.erb     # Metadata
├── _container.html.erb    # Card wrapper
└── container/
    ├── _header.html.erb
    ├── _body.html.erb
    └── _footer.html.erb
```

**Main View Example:**

```erb
<!-- app/views/cards/show.html.erb -->
<%= turbo_stream_from @card %>
<%= turbo_stream_from @card, :activity %>

<div data-controller="beacon lightbox">
  <%= render "cards/container", card: @card %>
  <%= render "cards/activity", card: @card unless @card.drafted? %>
</div>
```

**Partial Naming:**
- Descriptive names: `_header.html.erb`, `_content.html.erb`
- Group related partials in subdirectories
- Keep partials small (< 50 lines)

---

## Helper Patterns

### Tag Builder Helpers

Create semantic, reusable tag builders:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def icon_tag(name, **options)
    tag.span \
      class: class_names("icon icon--#{name}", options.delete(:class)),
      "aria-hidden": true,
      **options
  end

  def inline_svg(name)
    file_path = Rails.root.join("app/assets/images/#{name}.svg")
    return tag.span("(SVG not found)", class: "missing-svg") unless File.exist?(file_path)

    File.read(file_path).html_safe
  end

  def avatar_tag(user, size: :small, **options)
    classes = class_names("avatar avatar--#{size}", options.delete(:class))

    if user.avatar.attached?
      image_tag user.avatar.variant(:small), class: classes, alt: user.name, **options
    else
      tag.span user.initials,
               class: class_names(classes, "avatar--initials"),
               **options
    end
  end
end
```

### Auto-linking Content

Automatically convert URLs and emails to links:

```ruby
# app/helpers/html_helper.rb
module HtmlHelper
  EMAIL_REGEXP = /\b[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\b/
  URL_REGEXP = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  def format_html(html)
    fragment = Nokogiri::HTML.fragment(html)
    auto_link_urls(fragment)
    auto_link_emails(fragment)
    fragment.to_html.html_safe
  end

  private
    EXCLUDED_ELEMENTS = %w[ a figcaption pre code ]

    def auto_linkable_node?(node)
      node.text? && node.ancestors.none? { |a| EXCLUDED_ELEMENTS.include?(a.name) }
    end
end
```

### Stimulus-Aware Form Helpers

Integrate Stimulus with forms:

```ruby
# app/helpers/forms_helper.rb
module FormsHelper
  def auto_submit_form_with(**attributes, &block)
    data = attributes.delete(:data) || {}
    data[:controller] = "auto-submit #{data[:controller]}".strip
    data[:action] = "change->auto-submit#submit #{data[:action]}".strip

    form_with(**attributes, data: data, &block)
  end

  def dialog_form_with(**attributes, &block)
    data = attributes.delete(:data) || {}
    data[:action] = "turbo:submit-end->dialog#close #{data[:action]}".strip

    form_with(**attributes, data: data, &block)
  end
end
```

### ARIA Attribute Helpers

Manage accessibility consistently:

```ruby
# app/helpers/accessibility_helper.rb
module AccessibilityHelper
  def aria_current(condition, value: "page")
    { "aria-current": value } if condition
  end

  def aria_label(label)
    { "aria-label": label }
  end

  def aria_describedby(*ids)
    { "aria-describedby": ids.join(" ") } if ids.any?
  end
end

# Usage in views
<%= link_to "Home", root_path, **aria_current(current_page?(root_path)) %>
<%= button_tag "Delete", **aria_label("Delete card") %>
```

### Data Attribute Merging

Merge data attributes cleanly:

```ruby
# app/helpers/data_helper.rb
module DataHelper
  def merge_data_attributes(base_data, additional_data)
    base_data.merge(additional_data) do |key, old_val, new_val|
      case key
      when :controller, :action, :class
        [old_val, new_val].join(" ").strip
      else
        new_val
      end
    end
  end

  # Usage
  def card_tag(card, **options)
    base_data = { controller: "drag-and-drop", card_id_value: card.id }
    user_data = options.delete(:data) || {}

    tag.article \
      id: dom_id(card),
      data: merge_data_attributes(base_data, user_data),
      **options
  end
end
```

---

## Turbo & Real-time Updates

### Turbo Streams for Dynamic Updates

```erb
<!-- app/views/cards/update.turbo_stream.erb -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    method: :morph,
    locals: { card: @card } %>

<%= turbo_stream.update dom_id(@card, :meta) do %>
  <%= render "cards/meta", card: @card %>
<% end %>
```

### Broadcasting Real-time Updates

**In Views (Subscribe):**

```erb
<%= turbo_stream_from @card %>
<%= turbo_stream_from @card, :activity %>
<%= turbo_stream_from @board %>
```

**In Models (Broadcast):**

```ruby
class Card < ApplicationRecord
  include Broadcastable

  after_update_commit :broadcast_changes

  private
    def broadcast_changes
      broadcast_replace_to self,
        target: dom_id(self, :container),
        partial: "cards/container",
        locals: { card: self }
    end
end
```

### Broadcast Suppression

Prevent unnecessary broadcasts:

```ruby
# app/models/card/broadcastable.rb
module Card::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes
    before_update :remember_if_preview_changed
  end

  private
    def remember_if_preview_changed
      @preview_changed = title_changed? || column_id_changed?
    end

    def broadcast_preview_update
      return unless @preview_changed

      broadcast_replace_to self,
        target: dom_id(self, :preview),
        partial: "cards/preview",
        locals: { card: self }
    end
end

# Suppress during bulk operations
Card.suppressing_turbo_broadcasts do
  cards.each { |card| card.update!(status: :archived) }
end
```

### Morphing vs Replacing

```erb
<!-- Morph preserves focus and form state -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    method: :morph,
    locals: { card: @card } %>

<!-- Replace for complete re-render -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    locals: { card: @card } %>
```

### Conditional Broadcasting

Only broadcast what changed:

```ruby
class Card < ApplicationRecord
  after_update_commit :broadcast_changes

  private
    def broadcast_changes
      broadcast_title_update if saved_change_to_title?
      broadcast_status_update if saved_change_to_status?
      broadcast_move if saved_change_to_column_id?
    end

    def broadcast_title_update
      broadcast_replace_to self, :title,
        target: dom_id(self, :title),
        partial: "cards/title",
        locals: { card: self }
    end

    def broadcast_move
      # Remove from old column
      broadcast_remove_to [board, previous_column], :cards,
        target: dom_id(self)

      # Add to new column
      broadcast_prepend_to [board, column], :cards,
        target: dom_id(column, :cards),
        partial: "cards/card",
        locals: { card: self }
    end
end
```

---

## Stimulus Controllers

### Basic Controller Structure

```javascript
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dialog" ]
  static values = {
    modal: { type: Boolean, default: false }
  }

  connect() {
    this.dialogTarget.setAttribute("aria-hidden", "true")
  }

  open() {
    if (this.modalValue) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.show()
    }

    this.loadLazyFrames()
    this.dialogTarget.setAttribute("aria-hidden", "false")
    this.dispatch("opened")
  }

  close() {
    this.dialogTarget.close()
    this.dispatch("closed")
  }

  // Private methods use naming convention
  loadLazyFrames() {
    this.dialogTarget
      .querySelectorAll("turbo-frame[loading='lazy']")
      .forEach(frame => { frame.loading = "eager" })
  }
}
```

### Private Fields Pattern

Use `#` prefix for private fields:

```javascript
// app/javascript/controllers/auto_save_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #timer
  #delay = 1000

  connect() {
    this.element.addEventListener("input", () => this.#scheduleSave())
  }

  disconnect() {
    this.#cancelTimer()
    if (this.#dirty) {
      this.#save()
    }
  }

  #scheduleSave() {
    this.#cancelTimer()
    this.#timer = setTimeout(() => this.#save(), this.#delay)
  }

  #cancelTimer() {
    if (this.#timer) {
      clearTimeout(this.#timer)
      this.#timer = null
    }
  }

  async #save() {
    this.#cancelTimer()
    const form = this.element.closest("form")

    await fetch(form.action, {
      method: form.method,
      body: new FormData(form)
    })
  }

  get #dirty() {
    return !!this.#timer
  }
}
```

### Async/Await Patterns

Handle asynchronous operations cleanly:

```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "results" ]
  static values = { url: String }

  #abortController

  async search() {
    const query = this.inputTarget.value

    if (query.length < 3) {
      this.clearResults()
      return
    }

    this.#abortPreviousRequest()
    this.showLoading()

    try {
      const results = await this.#fetchResults(query)
      this.displayResults(results)
    } catch (error) {
      if (error.name !== "AbortError") {
        this.handleError(error)
      }
    }
  }

  #abortPreviousRequest() {
    this.#abortController?.abort()
    this.#abortController = new AbortController()
  }

  async #fetchResults(query) {
    const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
    const response = await fetch(url, {
      signal: this.#abortController.signal
    })
    return response.json()
  }

  showLoading() {
    this.resultsTarget.innerHTML = '<div class="loading">Searching...</div>'
    this.resultsTarget.setAttribute("aria-busy", "true")
  }
}
```

### Custom Event Dispatching

Communicate between controllers:

```javascript
// app/javascript/controllers/modal_controller.js
export default class extends Controller {
  open() {
    this.element.showModal()
    this.dispatch("opened", {
      detail: { element: this.element },
      prefix: "modal"  // Event: "modal:opened"
    })
  }

  close() {
    this.element.close()
    this.dispatch("closed", { prefix: "modal" })
  }
}

// Listening in another controller
export default class extends Controller {
  connect() {
    window.addEventListener("modal:opened", this.#handleModalOpened.bind(this))
  }

  #handleModalOpened = (event) => {
    if (event.detail.element.contains(this.element)) {
      this.element.querySelector("input")?.focus()
    }
  }
}
```

**HTML Usage:**

```erb
<div data-controller="dialog">
  <button data-action="click->dialog#open">Open</button>

  <dialog data-dialog-target="dialog"
          data-action="click->dialog#backdropClick">
    <h2>Dialog Content</h2>
    <button data-action="click->dialog#close">Close</button>
  </dialog>
</div>
```

---

## CSS Architecture

### Modern CSS Layers

```css
/* app/assets/stylesheets/application.css */
@layer base, components, utilities;

/* app/assets/stylesheets/base.css */
@layer base {
  :root {
    /* Colors */
    --color-canvas: #ffffff;
    --color-ink: #1a1a1a;
    --color-border: #e5e7eb;
    --color-primary: #0066cc;

    /* Spacing */
    --space-1: 0.25rem;
    --space-2: 0.5rem;
    --space-4: 1rem;

    /* Typography */
    --font-sans: system-ui, sans-serif;
    --text-sm: 0.875rem;
    --text-base: 1rem;
  }

  body {
    font-family: var(--font-sans);
    color: var(--color-ink);
    background: var(--color-canvas);
  }

  /* Focus management */
  :is(a, button, input, textarea, select) {
    transition: 100ms ease-out;
    transition-property: background-color, border-color, box-shadow;

    &:where(:focus-visible) {
      outline: 2px solid var(--color-primary);
      outline-offset: 2px;
    }

    &:focus:not(:focus-visible) {
      outline: none;
    }
  }
}
```

### Logical Properties

Use logical properties for internationalization:

```css
/* app/assets/stylesheets/components/card.css */
@layer components {
  .card {
    padding-block: var(--space-4);
    padding-inline: var(--space-6);
    margin-block-end: var(--space-4);
    border-inline-start: 3px solid var(--card-color);
  }

  .card__title {
    margin-block-end: var(--space-2);
  }

  .card__actions {
    margin-inline-start: auto;
  }
}
```

### Component CSS with Nesting

```css
@layer components {
  .card {
    background: white;
    border-radius: 8px;
    border: 1px solid var(--color-border);

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    &__title {
      font-size: var(--text-lg);
      font-weight: 600;
    }

    /* State modifiers */
    &--golden {
      border-color: var(--color-gold);
      box-shadow: 0 0 0 1px var(--color-gold);
    }

    &--postponed {
      opacity: 0.6;
    }

    /* Hover states */
    &:hover {
      box-shadow: 0 2px 8px rgb(0 0 0 / 0.1);
    }

    /* Context-specific styles */
    .board--dark & {
      background: var(--color-dark-surface);
    }
  }
}
```

### Utility Classes

```css
@layer utilities {
  /* Logical padding */
  .pad-block { padding-block: var(--space-4); }
  .pad-inline { padding-inline: var(--space-4); }

  /* Flexbox */
  .flex { display: flex; }
  .flex-col { flex-direction: column; }
  .items-center { align-items: center; }
  .justify-between { justify-content: space-between; }
  .gap { gap: var(--gap-size, 1rem); }

  /* Accessibility */
  .visually-hidden {
    block-size: 1px;
    inline-size: 1px;
    clip-path: inset(50%);
    overflow: hidden;
    position: absolute;
    white-space: nowrap;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border-width: 0;
  }
}
```

---

## Frontend Checklist

### Before Every Commit

**Views:**
- [ ] Partitioned into small, focused partials (< 50 lines each)
- [ ] Helper methods for complex view logic
- [ ] No business logic in templates
- [ ] ARIA attributes for accessibility

**Turbo:**
- [ ] Subscribe with `turbo_stream_from`
- [ ] Use `method: :morph` for smooth updates
- [ ] Conditional broadcasting (only what changed)
- [ ] Suppress broadcasts during bulk operations

**Stimulus:**
- [ ] Controllers small and focused
- [ ] Use `static targets` and `static values`
- [ ] Private fields use `#` prefix
- [ ] Dispatch custom events for communication
- [ ] ARIA attributes managed properly

**CSS:**
- [ ] Use CSS custom properties for theming
- [ ] Logical properties for i18n
- [ ] Focus-visible for accessibility
- [ ] Layer-based organization
- [ ] Component naming follows BEM-like pattern

---

## Related Guides

- [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) - Models, controllers, security
- [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md) - Deployment, config, email
- [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) - Complete reference
- [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) - Top 20 patterns

---

**Remember:** Small partials, semantic helpers, progressive enhancement! ✨
