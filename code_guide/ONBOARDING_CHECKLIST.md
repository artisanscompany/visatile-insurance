# Rails Team Onboarding Checklist

> **Your first 30 days** - A structured path to mastering 37signals Rails patterns

---

## Week 1: Foundation & Setup

### Day 1: Environment & Introduction
- [ ] Clone repository and run `bin/setup`
- [ ] Start dev server with `bin/dev` and access app
- [ ] Read [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) (30 min)
- [ ] Browse the [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) table of contents
- [ ] Set up editor with RuboCop integration
- [ ] Run `bundle exec rubocop` to see code style in action

**Goal:** Understand the codebase philosophy and get environment running

### Day 2-3: Model Patterns
- [ ] Read [Model Patterns](./TEAM_CODING_STANDARDS.md#model-patterns) section
- [ ] Study 3 models in `app/models/` (start with `Card`, `Board`, `User`)
- [ ] Identify concerns in each model
- [ ] Practice: Add a simple scope to an existing model
- [ ] Run tests: `bin/rails test test/models/`

**Exercise:** Create a new concern for a model that adds a simple behavior
```ruby
# app/models/concerns/timestampable.rb
module Timestampable
  extend ActiveSupport::Concern

  def human_created_at
    created_at.strftime("%B %d, %Y")
  end
end
```

### Day 4-5: Controller Patterns
- [ ] Read [Controller Patterns](./TEAM_CODING_STANDARDS.md#controller-patterns) section
- [ ] Study 3 controllers (e.g., `BoardsController`, `Cards::ClosuresController`)
- [ ] Understand RESTful resource design (no custom actions!)
- [ ] Identify controller concerns being used
- [ ] Practice: Implement a simple singular resource controller

**Exercise:** Create a toggle resource for a feature
```ruby
# app/controllers/cards/pins_controller.rb
class Cards::PinsController < ApplicationController
  include CardScoped

  def create
    @card.pin!
    render_card_replacement
  end

  def destroy
    @card.unpin!
    render_card_replacement
  end
end
```

---

## Week 2: Security & Views

### Day 6-7: Security Patterns
- [ ] Read [Security Patterns](./TEAM_CODING_STANDARDS.md#security-patterns)
- [ ] Review authentication implementation in `app/controllers/concerns/authentication.rb`
- [ ] Study authorization helpers
- [ ] Understand parameter filtering
- [ ] Practice: Add a new authorization check

**Checklist - Security Essentials:**
- [ ] Always use `params.expect` for strong parameters
- [ ] Always use parameterized queries (never string interpolation)
- [ ] Always escape user content in views (no `raw` unless sanitized)
- [ ] Use `httponly: true` for session cookies
- [ ] Filter sensitive parameters from logs

**Exercise:** Add authorization to a controller action
```ruby
before_action :ensure_can_edit_board, only: %i[ update ]

private
  def ensure_can_edit_board
    head :forbidden unless @board.editable_by?(Current.user)
  end
```

### Day 8-10: View & Frontend Patterns
- [ ] Read [View & Frontend Patterns](./TEAM_CODING_STANDARDS.md#view--frontend-patterns)
- [ ] Study partial organization in `app/views/cards/`
- [ ] Read [Helper Patterns](./TEAM_CODING_STANDARDS.md#helper-patterns)
- [ ] Review helpers in `app/helpers/`
- [ ] Practice: Create a helper method for a common UI pattern

**Exercise:** Create a reusable helper
```ruby
# app/helpers/badges_helper.rb
module BadgesHelper
  def status_badge(status)
    classes = class_names(
      "badge",
      "badge--#{status}",
      ("badge--active" if status == "active")
    )

    tag.span status.humanize, class: classes
  end
end
```

---

## Week 3: Turbo, Stimulus & Testing

### Day 11-13: Turbo & Real-time Updates
- [ ] Read [Turbo & Real-time Updates](./TEAM_CODING_STANDARDS.md#turbo--real-time-updates)
- [ ] Study Turbo Stream usage in controllers
- [ ] Understand `broadcasts_refreshes` in models
- [ ] Learn about morphing vs replacing
- [ ] Practice: Add a Turbo Stream response

**Exercise:** Implement a Turbo Stream update
```erb
<!-- app/views/cards/update.turbo_stream.erb -->
<%= turbo_stream.replace dom_id(@card),
    partial: "cards/card",
    method: :morph,
    locals: { card: @card } %>
```

### Day 14-15: Stimulus Controllers
- [ ] Read [Stimulus Advanced Patterns](./TEAM_CODING_STANDARDS.md#stimulus-advanced-patterns)
- [ ] Study 3 Stimulus controllers in `app/javascript/controllers/`
- [ ] Understand targets, values, and actions
- [ ] Learn about private fields (`#field`)
- [ ] Practice: Create a simple Stimulus controller

**Exercise:** Build a toggle controller
```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content" ]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

### Day 16-18: Testing Patterns
- [ ] Read [Testing Patterns](./TEAM_CODING_STANDARDS.md#testing-patterns)
- [ ] Study test files in `test/models/` and `test/controllers/`
- [ ] Understand fixture usage
- [ ] Learn system test patterns
- [ ] Run full test suite: `bin/rails test`
- [ ] Practice: Write tests for your earlier exercises

**Exercise:** Write a complete test
```ruby
require "test_helper"

class CardTest < ActiveSupport::TestCase
  test "pinning card sets pinned_at" do
    card = cards(:logo)

    assert_nil card.pinned_at

    card.pin!

    assert_not_nil card.reload.pinned_at
  end
end
```

---

## Week 4: Advanced Patterns & Production

### Day 19-21: Background Jobs & Advanced Models
- [ ] Read [Background Jobs](./TEAM_CODING_STANDARDS.md#background-jobs)
- [ ] Study job organization in `app/jobs/`
- [ ] Understand `_later` vs `_now` convention
- [ ] Learn about account context preservation
- [ ] Read [Form Objects & POROs](./TEAM_CODING_STANDARDS.md#form-objects--poros)
- [ ] Practice: Create a background job

**Exercise:** Implement a job with model concern
```ruby
# app/models/concerns/card/notifiable.rb
module Card::Notifiable
  def notify_watchers_later
    Card::NotifyWatchersJob.perform_later(self)
  end

  def notify_watchers_now
    watchers.each do |user|
      Notification.create!(user: user, source: self)
    end
  end
end
```

### Day 22-24: Infrastructure & Configuration
- [ ] Read [Rails Extensions & Monkey Patching](./TEAM_CODING_STANDARDS.md#rails-extensions--monkey-patching)
- [ ] Study extensions in `lib/rails_ext/`
- [ ] Read [Configuration & Environment](./TEAM_CODING_STANDARDS.md#configuration--environment)
- [ ] Understand multi-tenancy setup
- [ ] Review [Current Attributes & Context](./TEAM_CODING_STANDARDS.md#current-attributes--context)

### Day 25-27: Email, Files & Deployment
- [ ] Read [Email Patterns](./TEAM_CODING_STANDARDS.md#email-patterns)
- [ ] Study mailers in `app/mailers/`
- [ ] Read [File Upload & Storage](./TEAM_CODING_STANDARDS.md#file-upload--storage)
- [ ] Review [Deployment & DevOps](./TEAM_CODING_STANDARDS.md#deployment--devops)
- [ ] Understand Kamal deployment configuration

### Day 28-30: First Feature PR
- [ ] Pick a small feature from backlog
- [ ] Write tests first (TDD)
- [ ] Implement following all patterns learned
- [ ] Run RuboCop: `bundle exec rubocop`
- [ ] Create PR following [RESTful design](./TEAM_CODING_STANDARDS.md#restful-resource-design)
- [ ] Get code review from team
- [ ] Deploy to staging and verify

---

## Quick Reference Checklist

Before every PR, check:

### Code Organization
- [ ] Models: Concerns → Associations → Validations → Callbacks → Scopes
- [ ] Controllers: RESTful resources only (no custom actions)
- [ ] Views: Partitioned into small, focused partials
- [ ] Tests: Cover all public methods

### Security
- [ ] Strong parameters with `params.expect`
- [ ] Parameterized queries (no string interpolation)
- [ ] User content escaped in views
- [ ] Authorization checks in place

### Performance
- [ ] Preload associations to avoid N+1
- [ ] Use scopes for chainable queries
- [ ] Background jobs for slow operations

### Style
- [ ] Methods under 15 lines
- [ ] Clear, intention-revealing names
- [ ] Private methods ordered by invocation flow
- [ ] RuboCop passes: `bundle exec rubocop`

---

## Learning Resources

### Internal Docs
- [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) - Complete reference
- [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) - Top 20 patterns
- [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) - Models, controllers, security
- [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md) - Views, Turbo, Stimulus
- [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md) - Deployment, config

### External Resources
- [Rails Guides](https://guides.rubyonrails.org/)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Rubocop Rails Omakase](https://github.com/rails/rubocop-rails-omakase)

### Commands Reference
```bash
bin/setup              # Initial setup
bin/dev                # Start dev server
bin/rails test         # Run all tests
bin/rails test:system  # Run system tests
bin/ci                 # Full CI suite
bundle exec rubocop    # Check code style
bin/rails console      # Rails console
```

---

## Completion Checklist

After 30 days, you should be able to:

- [ ] Write models following 37signals patterns
- [ ] Create RESTful controllers without custom actions
- [ ] Implement secure authentication and authorization
- [ ] Build views with Turbo and Stimulus
- [ ] Write comprehensive tests
- [ ] Use background jobs appropriately
- [ ] Understand multi-tenancy architecture
- [ ] Submit production-ready PRs
- [ ] Review code using team standards

**Welcome to the team!** 🎉

Got questions? Ask in #engineering or review the complete [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md).
