# 37signals Rails Coding Standards - Documentation Suite

> **Complete reference** for writing clean, maintainable Rails code based on the Fizzy codebase

---

## 📚 Documentation Overview

This repository contains a comprehensive set of coding standards and guides extracted from the 37signals Fizzy codebase. Use these documents to onboard new team members, maintain code quality, and ensure consistency across your Rails applications.

### Document Structure

```
📁 Fizzy Coding Standards
├── 📖 TEAM_CODING_STANDARDS.md          [Complete Reference - 2000+ lines]
├── ⚡ QUICK_START_GUIDE.md              [Top 20 Patterns - Start Here!]
├── 🎓 ONBOARDING_CHECKLIST.md           [30-Day Learning Path]
├── 🔧 .rubocop.yml                      [Automated Style Enforcement]
│
├── 📘 BACKEND_GUIDE.md                  [Models, Controllers, Security, Database, Jobs]
├── 📗 FRONTEND_GUIDE.md                 [Views, Helpers, Turbo, Stimulus, CSS]
└── 📙 INFRASTRUCTURE_GUIDE.md           [Config, Email, Files, Deployment]
```

---

## 🚀 Getting Started

### For New Team Members

1. **Start Here:** Read [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) (15 minutes)
   - Get the essential patterns you need to be productive immediately
   - Covers top 20 most important patterns

2. **Follow the Path:** Use [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md) (30 days)
   - Week-by-week structured learning
   - Hands-on exercises for each pattern
   - Checkpoints to track progress

3. **Deep Dive:** Reference domain-specific guides as needed
   - [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) for server-side work
   - [FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md) for client-side work
   - [INFRASTRUCTURE_GUIDE.md](./INFRASTRUCTURE_GUIDE.md) for config/deployment

### For Experienced Developers

1. **Review:** Skim [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) table of contents
2. **Configure:** Set up [.rubocop.yml](./.rubocop.yml) in your editor
3. **Reference:** Use domain guides for specific patterns

---

## 📖 Document Details

### TEAM_CODING_STANDARDS.md
**Complete Reference Guide** - 23 comprehensive sections covering every aspect of Rails development

**When to use:** Complete reference, code reviews, architectural decisions

**Covers:**
- Core Philosophy & Structure
- Models, Controllers, Security
- Views, Turbo, Stimulus, CSS
- Testing, Database, Background Jobs
- Rails Extensions, Email, Files
- Configuration & Deployment

**Size:** ~2000 lines | **Read time:** 2-3 hours

---

### QUICK_START_GUIDE.md
**Essential Patterns** - Top 20 patterns every Rails developer needs

**When to use:** Onboarding, quick reference, PR reviews

**Covers:**
1. Model structure
2. RESTful controllers
3. Thin controllers, rich models
4. Concerns for composition
5. Strong parameters
6. Security (SQL injection, XSS, sessions)
7. Multi-tenancy
8. Turbo streams
9. Stimulus controllers
10. Modern CSS
11. Helper methods
12. View partials
13. Background jobs
14. Scopes for queries
15. Preloading (N+1 prevention)
16. Method ordering
17. Form objects
18. Testing patterns
19. And more...

**Size:** ~400 lines | **Read time:** 15-20 minutes

---

### ONBOARDING_CHECKLIST.md
**30-Day Learning Path** - Structured onboarding for new team members

**When to use:** New hire onboarding, skill assessment

**Structure:**
- **Week 1:** Foundation (Environment, Models, Controllers)
- **Week 2:** Security & Views (Security patterns, Views, Frontend)
- **Week 3:** Turbo, Stimulus & Testing (Real-time updates, JS, Testing)
- **Week 4:** Advanced Patterns (Jobs, Infrastructure, First PR)

Each day includes:
- Reading assignments
- Hands-on exercises
- Code examples
- Checkpoints

**Size:** ~300 lines | **Completion time:** 30 days

---

### .rubocop.yml
**Automated Style Enforcement** - RuboCop configuration enforcing 37signals patterns

**When to use:** CI/CD, pre-commit hooks, editor integration

**Features:**
- Based on `rubocop-rails-omakase`
- Custom rules for 37signals patterns
- Method ordering enforcement
- Security checks (SQL injection, XSS)
- Performance optimizations
- Rails-specific cops

**Usage:**
```bash
# Check code
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Check specific files
bundle exec rubocop app/models/card.rb
```

---

### BACKEND_GUIDE.md
**Server-Side Patterns** - Models, controllers, security, database, jobs

**When to use:** Backend development, API design, database work

**Sections:**
1. Model Patterns (structure, concerns, associations, multi-tenancy)
2. Controller Patterns (RESTful, thin controllers, concerns)
3. Security Patterns (CSRF, SQL injection, XSS, sessions)
4. Database & Query Patterns (migrations, schema, optimization)
5. Background Jobs (patterns, multi-tenant context)
6. Form Objects & POROs (when to use, patterns)

**Size:** ~650 lines | **Read time:** 45 minutes

---

### FRONTEND_GUIDE.md
**Client-Side Patterns** - Views, helpers, Turbo, Stimulus, CSS

**When to use:** Frontend development, UI work, real-time features

**Sections:**
1. View Organization (partials, naming conventions)
2. Helper Patterns (tag builders, auto-linking, Stimulus integration, ARIA)
3. Turbo & Real-time Updates (streams, broadcasting, morphing, suppression)
4. Stimulus Controllers (structure, private fields, async/await, events)
5. CSS Architecture (layers, logical properties, components, utilities)

**Size:** ~600 lines | **Read time:** 40 minutes

---

### INFRASTRUCTURE_GUIDE.md
**Configuration & Deployment** - Rails extensions, email, files, config, deploy

**When to use:** Infrastructure work, deployment, configuration

**Sections:**
1. Rails Extensions & Monkey Patching (organization, hooks, prepend vs include)
2. Email Patterns (ApplicationMailer, unsubscribe headers, previews)
3. File Upload & Storage (variants, ActiveStorage, validation)
4. Current Attributes & Context (multi-tenancy, request tracking, jobs)
5. Routing Conventions (scope module vs namespace, singular resources)
6. Configuration & Environment (application config, credentials, ENV)
7. Deployment & DevOps (Kamal, health checks, migrations)

**Size:** ~550 lines | **Read time:** 35 minutes

---

## 🎯 Quick Reference by Task

### "I need to..."

**...get started quickly**
→ [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)

**...onboard a new team member**
→ [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md)

**...write a model**
→ [BACKEND_GUIDE.md#model-patterns](./BACKEND_GUIDE.md#model-patterns)

**...create a controller**
→ [BACKEND_GUIDE.md#controller-patterns](./BACKEND_GUIDE.md#controller-patterns)

**...secure my app**
→ [BACKEND_GUIDE.md#security-patterns](./BACKEND_GUIDE.md#security-patterns)

**...build a view**
→ [FRONTEND_GUIDE.md#view-organization](./FRONTEND_GUIDE.md#view-organization)

**...add real-time updates**
→ [FRONTEND_GUIDE.md#turbo--real-time-updates](./FRONTEND_GUIDE.md#turbo--real-time-updates)

**...write JavaScript**
→ [FRONTEND_GUIDE.md#stimulus-controllers](./FRONTEND_GUIDE.md#stimulus-controllers)

**...optimize queries**
→ [BACKEND_GUIDE.md#database--query-patterns](./BACKEND_GUIDE.md#database--query-patterns)

**...create a background job**
→ [BACKEND_GUIDE.md#background-jobs](./BACKEND_GUIDE.md#background-jobs)

**...send emails**
→ [INFRASTRUCTURE_GUIDE.md#email-patterns](./INFRASTRUCTURE_GUIDE.md#email-patterns)

**...handle file uploads**
→ [INFRASTRUCTURE_GUIDE.md#file-upload--storage](./INFRASTRUCTURE_GUIDE.md#file-upload--storage)

**...deploy the app**
→ [INFRASTRUCTURE_GUIDE.md#deployment--devops](./INFRASTRUCTURE_GUIDE.md#deployment--devops)

**...write tests**
→ [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) + [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md)

**...review code**
→ [TEAM_CODING_STANDARDS.md](./TEAM_CODING_STANDARDS.md) + [.rubocop.yml](./.rubocop.yml)

---

## 🔍 Key Principles

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

## 🛠 Tools & Integration

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

### CI/CD Integration

```yaml
# .github/workflows/ci.yml
- name: RuboCop
  run: bundle exec rubocop

- name: Tests
  run: bin/rails test
```

### Pre-commit Hook

```bash
#!/bin/sh
bundle exec rubocop $(git diff --cached --name-only --diff-filter=ACM | grep '\.rb$')
```

---

## 📊 Document Stats

| Document | Lines | Read Time | Purpose |
|----------|-------|-----------|---------|
| TEAM_CODING_STANDARDS.md | ~2000 | 2-3 hours | Complete reference |
| QUICK_START_GUIDE.md | ~400 | 15-20 min | Essential patterns |
| ONBOARDING_CHECKLIST.md | ~300 | 30 days | Structured learning |
| BACKEND_GUIDE.md | ~650 | 45 min | Server-side patterns |
| FRONTEND_GUIDE.md | ~600 | 40 min | Client-side patterns |
| INFRASTRUCTURE_GUIDE.md | ~550 | 35 min | Config & deployment |
| **Total** | **~4500** | **~6 hours** | **Complete coverage** |

---

## 🎓 Learning Path Recommendations

### For Junior Developers
1. QUICK_START_GUIDE.md (Day 1)
2. ONBOARDING_CHECKLIST.md (Weeks 1-4)
3. Domain guides as you work (ongoing)
4. TEAM_CODING_STANDARDS.md (Month 2+)

### For Mid-Level Developers
1. QUICK_START_GUIDE.md (Day 1)
2. Skim TEAM_CODING_STANDARDS.md (Week 1)
3. Deep dive domain guides (Week 1-2)
4. Reference as needed (ongoing)

### For Senior Developers
1. TEAM_CODING_STANDARDS.md TOC (Day 1)
2. Domain guides for architecture patterns (Week 1)
3. Use as reference for code reviews (ongoing)
4. Mentor others using guides (ongoing)

---

## 🤝 Contributing

When you discover new patterns or improvements:

1. Document the pattern with code examples
2. Explain the rationale (why, not just what)
3. Include good vs bad comparisons
4. Add to appropriate guide
5. Update this README if needed

---

## 📞 Support

**Questions about patterns?**
- Check the appropriate domain guide
- Review TEAM_CODING_STANDARDS.md for complete details
- Ask in #engineering channel

**Found an issue?**
- Create an issue with specific section reference
- Propose improvements with examples

---

## 🎉 Success Metrics

After using these guides, developers should:

- ✅ Write RESTful controllers without custom actions
- ✅ Structure models following the standard order
- ✅ Implement security patterns by default
- ✅ Build views with proper Turbo/Stimulus integration
- ✅ Pass RuboCop with team configuration
- ✅ Submit production-ready PRs within 30 days
- ✅ Review code using team standards

---

**Welcome to writing beautiful Rails code! 🚀**

For the complete picture, start with [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) and follow the [ONBOARDING_CHECKLIST.md](./ONBOARDING_CHECKLIST.md).
