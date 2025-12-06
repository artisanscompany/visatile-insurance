# 37signals Rails Coding Standards

> Complete coding standards and guides extracted from the 37signals Fizzy codebase

---

## Overview

This repository contains comprehensive Rails coding standards based on patterns from the 37signals Fizzy codebase. Use these guides to write clean, maintainable Rails applications following industry best practices.

**Total Documentation:** ~4,500 lines covering every aspect of Rails development

---

## Quick Start

**New to the team?** Start here:

1. Read [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) (15 minutes)
2. Follow [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md) (30 days)
3. Reference domain guides as you work

**Experienced developer?** Jump to the domain-specific guides you need.

---

## Documentation

### Essential Guides

- **[QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)** - Top 20 patterns (15-min read)
- **[ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md)** - 30-day learning path
- **[README_CODING_STANDARDS.md](./README_CODING_STANDARDS.md)** - Complete navigation hub

### Domain-Specific Guides

- **[BACKEND_GUIDE.md](./BACKEND_GUIDE.md)** - Models, Controllers, Security, Database, Jobs
- **[FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md)** - Views, Helpers, Turbo, Stimulus, CSS
- **[INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md)** - Config, Email, Files, Deployment

### Complete Reference

- **[TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md)** - Complete 2000+ line reference

### Code Quality

- **[.rubocop.yml](./.rubocop.yml)** - RuboCop configuration enforcing these standards

---

## What's Covered

### Backend Development
- Model structure and organization
- RESTful controller design
- Security patterns (CSRF, XSS, SQL injection)
- Database migrations and queries
- Background jobs with Solid Queue
- Form objects and POROs

### Frontend Development
- View organization and partials
- Helper patterns with tag builders
- Turbo streams and real-time updates
- Stimulus controllers
- Modern CSS architecture

### Infrastructure
- Rails extensions organization
- Email patterns (RFC 8058 unsubscribe)
- File uploads with ActiveStorage
- Multi-tenancy with Current attributes
- Configuration and environment setup
- Deployment with Kamal

### Testing
- Minitest patterns
- System tests with Capybara
- VCR for external services
- Multi-tenant test helpers
- UUID fixture generation

---

## Key Principles

All guides follow these core 37signals principles:

1. **Vanilla Rails First** - Embrace Rails conventions, avoid over-architecting
2. **Rich Models, Thin Controllers** - Business logic in models, controllers coordinate
3. **RESTful Design** - Create new resources instead of custom actions
4. **Explicit Over Implicit** - Clear, readable code beats clever tricks
5. **Concerns for Composition** - Small, focused mixins to compose behavior
6. **Security by Default** - Parameterize queries, escape output, secure sessions
7. **Test Everything** - Comprehensive testing at all levels
8. **Modern Rails** - Leverage Turbo, Stimulus, and Hotwire

---

## Usage

### For Teams

1. **Onboarding:** Use [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md) for new hires
2. **Code Reviews:** Reference [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md)
3. **CI/CD:** Integrate [.rubocop.yml](./.rubocop.yml) into your pipeline

### For Individuals

1. **Quick Reference:** Bookmark [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
2. **Deep Dive:** Study domain guides for your current work
3. **Complete Understanding:** Read [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md)

### RuboCop Integration

```bash
# Copy .rubocop.yml to your Rails project
cp .rubocop.yml /path/to/your/project/

# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Editor Setup

**VS Code:**
```json
{
  "ruby.rubocop.onSave": true,
  "ruby.format": "rubocop"
}
```

**RubyMine:**
Settings → Editor → Inspections → Ruby → Enable RuboCop

---

## Learning Paths

### Junior Developers
1. QUICK_START_GUIDE.md (Day 1)
2. ONBOARDING_CHECKLIST.md (Weeks 1-4)
3. Domain guides as you work (ongoing)
4. TEAM_CODING_STANDARDS.md (Month 2+)

### Mid-Level Developers
1. QUICK_START_GUIDE.md (Day 1)
2. Skim TEAM_CODING_STANDARDS.md (Week 1)
3. Deep dive domain guides (Week 1-2)
4. Reference as needed (ongoing)

### Senior Developers
1. TEAM_CODING_STANDARDS.md TOC (Day 1)
2. Domain guides for architecture patterns (Week 1)
3. Use as reference for code reviews (ongoing)
4. Mentor others using guides (ongoing)

---

## Document Stats

| Document | Lines | Read Time | Purpose |
|----------|-------|-----------|---------|
| QUICK_START_GUIDE.md | ~400 | 15-20 min | Essential patterns |
| ONBOARDING_CHECKLIST.md | ~300 | 30 days | Structured learning |
| BACKEND_GUIDE.md | ~650 | 45 min | Server-side patterns |
| FRONTEND_GUIDE.md | ~600 | 40 min | Client-side patterns |
| INFRASTRUCTURE_GUIDE.md | ~550 | 35 min | Config & deployment |
| TEAM_CODING_STANDARDS.md | ~2000 | 2-3 hours | Complete reference |
| **Total** | **~4500** | **~6 hours** | **Complete coverage** |

---

## Contributing

Found a pattern that should be documented? Please:

1. Document with code examples
2. Explain the rationale (why, not just what)
3. Include good vs bad comparisons
4. Submit a pull request

---

## Credits

These standards are extracted from the [37signals Fizzy](https://github.com/basecamp/fizzy) codebase, an open-source kanban-style project management tool built with Rails 8.

Special thanks to:
- 37signals/Basecamp for open-sourcing Fizzy
- The Rails core team for excellent conventions
- The Ruby community for best practices

---

## License

This documentation is provided as-is for educational purposes. The original Fizzy codebase is licensed under MIT by 37signals.

---

**Start writing beautiful Rails code!** 🚀

Begin with [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) or jump to [README_CODING_STANDARDS.md](./README_CODING_STANDARDS.md) for complete navigation.
