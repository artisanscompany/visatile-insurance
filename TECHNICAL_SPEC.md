# Visatile Insurance Platform - Technical Specification

> This document contains everything needed to rebuild this application in Ruby on Rails.
> It covers every database table, API endpoint, service integration, authentication flow,
> and business logic pattern in full detail.

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Architecture Overview](#2-architecture-overview)
3. [Database Schema](#3-database-schema)
4. [Core Pattern: State-as-Records](#4-core-pattern-state-as-records)
5. [Authentication & Authorization](#5-authentication--authorization)
6. [API Endpoints](#6-api-endpoints)
7. [Service Integrations](#7-service-integrations)
8. [Policy Fulfillment Pipeline](#8-policy-fulfillment-pipeline)
9. [Email System](#9-email-system)
10. [Frontend Architecture](#10-frontend-architecture)
11. [Insurance Purchase Flow](#11-insurance-purchase-flow)
12. [Configuration & Environment Variables](#12-configuration--environment-variables)
13. [Rails Implementation Guidance](#13-rails-implementation-guidance)

---

## 1. Product Overview

A travel insurance SaaS platform with two main user experiences:

**Public Insurance Funnel** (no login required):
1. User gets a price quote by entering travel dates, countries, coverage tier, and traveler birth dates
2. User reviews the quote
3. User fills in traveler details (names, passports)
4. User provides email and is redirected to Stripe Checkout
5. After payment, the system automatically creates the insurance contract with an external provider (Insurs API), confirms it, downloads the PDF certificate, and stores it

**Authenticated Dashboard** (login required):
- View and download insurance policies (own + team policies)
- Create and manage teams (invite members, assign roles)
- Admin panel for superusers (manage users, retry failed policies, initiate refunds)

**Authentication**: Two methods - password login and passwordless OTP (email code) login.

---

## 2. Architecture Overview

### Current Stack (Python)
- **Backend**: FastAPI + SQLModel (SQLAlchemy+Pydantic) + PostgreSQL
- **Frontend**: React 19 + TanStack Router + TanStack Query + shadcn/ui + Tailwind CSS v4
- **Payments**: Stripe Checkout (hosted page, not embedded)
- **Insurance Provider**: Insurs.net REST API
- **Email**: SMTP via `emails` library with Jinja2/MJML templates

### Rails Equivalent Mapping
| Current | Rails Equivalent |
|---------|-----------------|
| FastAPI routes | Rails controllers |
| SQLModel ORM models | ActiveRecord models |
| Pydantic schemas | Strong Parameters + serializers (jbuilder/blueprinter) |
| Alembic migrations | Rails migrations |
| FastAPI Depends() | before_action filters, service objects |
| httpx AsyncClient | Faraday or HTTParty |
| JWT (PyJWT) | `jwt` gem or Devise with JWT |
| Argon2/bcrypt hashing | `bcrypt` gem (Rails default via `has_secure_password`) |
| pydantic-settings | Rails credentials + ENV vars |
| Stripe Python SDK | `stripe` Ruby gem |
| Tenacity retries | `retryable` gem |

---

## 3. Database Schema

All primary keys are UUIDs. All timestamps are `timestamptz` (timezone-aware UTC).

### 3.1 Core Entity Tables

#### `users`
```sql
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) NOT NULL UNIQUE,
  hashed_password VARCHAR,          -- NULL for OTP-only users
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  is_superuser  BOOLEAN NOT NULL DEFAULT FALSE,
  full_name     VARCHAR(255),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

**Key detail**: `hashed_password` is nullable. Users created via OTP login or team invite acceptance have no password. They can only authenticate via OTP.

#### `items`
```sql
CREATE TABLE items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       VARCHAR(255) NOT NULL,
  description VARCHAR(255),
  owner_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

*Note: Items is scaffolding from the template. Included for completeness but not core to the insurance domain.*

#### `insurance_policies`
```sql
CREATE TABLE insurance_policies (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id              UUID NOT NULL REFERENCES users(id),
  team_id               UUID REFERENCES teams(id),  -- nullable
  start_date            DATE NOT NULL,
  end_date              DATE NOT NULL,
  departure_country     VARCHAR(2) NOT NULL,         -- ISO alpha-2
  destination_countries JSONB NOT NULL,               -- ["DE", "FR", "IT"]
  locality_coverage     INTEGER NOT NULL,             -- Insurs locality ID (208=Europe, 237=Worldwide)
  coverage_tier         INTEGER NOT NULL CHECK (coverage_tier BETWEEN 1 AND 3),
  price_amount          NUMERIC(10,2) NOT NULL,
  price_currency        VARCHAR(3) NOT NULL DEFAULT 'USD',
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `travelers`
```sql
CREATE TABLE travelers (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id        UUID NOT NULL REFERENCES insurance_policies(id) ON DELETE CASCADE,
  first_name       VARCHAR(255) NOT NULL,
  last_name        VARCHAR(255) NOT NULL,
  birth_date       DATE NOT NULL,
  passport_number  VARCHAR(50) NOT NULL,
  passport_country VARCHAR(2) NOT NULL,  -- ISO alpha-2
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `otps`
```sql
CREATE TABLE otps (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email      VARCHAR(255) NOT NULL,
  code_hash  VARCHAR NOT NULL,            -- SHA-256 hex digest of the 6-digit code
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  attempts   INTEGER NOT NULL DEFAULT 0,
  is_used    BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_otps_email ON otps(email);
```

#### `teams`
```sql
CREATE TABLE teams (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(255) NOT NULL,
  slug       VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_teams_slug ON teams(slug);
```

**Slug generation**: lowercase name, non-alphanumeric chars replaced with hyphens, consecutive hyphens collapsed, leading/trailing hyphens stripped, then append `-` + 8-char random hex suffix. Example: `"My Team!"` -> `"my-team-a1b2c3d4"`.

#### `team_members`
```sql
CREATE TABLE team_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id    UUID NOT NULL REFERENCES teams(id),
  user_id    UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Important**: There is NO `role` column on this table. The member's current role is derived from the state tables (see Section 4).

#### `team_invites`
```sql
CREATE TABLE team_invites (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id    UUID NOT NULL REFERENCES teams(id),
  email      VARCHAR(255) NOT NULL,
  token_hash VARCHAR NOT NULL,            -- SHA-256 hex of the raw invite token
  role       VARCHAR(20) NOT NULL,        -- "member", "admin", or "owner"
  invited_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 3.2 Relationships

```
User 1──* Item           (owner_id, CASCADE delete)
User 1──* InsurancePolicy (owner_id)
User 1──* TeamMember      (user_id)
Team 1──* TeamMember      (team_id, CASCADE delete)
Team 1──* TeamInvite      (team_id, CASCADE delete)
Team 1──* InsurancePolicy (team_id, nullable)
InsurancePolicy 1──* Traveler (policy_id, CASCADE delete)
```

---

## 4. Core Pattern: State-as-Records

This is the most important architectural pattern in the application. Instead of a mutable `status` column on entities, each state transition creates a **new immutable row** in a dedicated state table. Current state is determined by finding the record with the most recent `created_at` across all relevant state tables.

### 4.1 Why This Pattern

- Full audit trail of every state transition with timestamps
- No lost history (a simple status column only shows current state)
- Each state can carry different metadata (e.g., `policy_failed` has `error_message`, `policy_payment_received` has `stripe_payment_intent_id`)
- Idempotent operations: check current state before acting

### 4.2 Policy State Tables (8 tables)

```sql
-- State 1: After Stripe checkout session created
CREATE TABLE policy_pending_payments (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id                  UUID NOT NULL REFERENCES insurance_policies(id),
  stripe_checkout_session_id VARCHAR(255) NOT NULL,
  created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State 2: After Stripe webhook confirms payment
CREATE TABLE policy_payment_receiveds (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id                  UUID NOT NULL REFERENCES insurance_policies(id),
  stripe_payment_intent_id   VARCHAR(255) NOT NULL,
  stripe_checkout_session_id VARCHAR(255) NOT NULL,
  amount_received            NUMERIC(10,2) NOT NULL,
  currency                   VARCHAR(3) NOT NULL,
  created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State 3: After contract created at Insurs API
CREATE TABLE policy_contract_createds (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id         UUID NOT NULL REFERENCES insurance_policies(id),
  insurs_order_id   VARCHAR(255) NOT NULL,
  insurs_police_num VARCHAR(255) NOT NULL,
  total_amount      VARCHAR(50) NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State 4: After contract confirmed at Insurs API
CREATE TABLE policy_contract_confirmeds (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id       UUID NOT NULL REFERENCES insurance_policies(id),
  insurs_order_id VARCHAR(255) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State 5: Terminal success - PDF downloaded and stored
CREATE TABLE policy_completeds (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id UUID NOT NULL REFERENCES insurance_policies(id),
  pdf_path  VARCHAR(512) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State: Failure at any step
CREATE TABLE policy_faileds (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id     UUID NOT NULL REFERENCES insurance_policies(id),
  failed_step   VARCHAR(100) NOT NULL,  -- "contract_creation", "contract_confirmation", "pdf_retrieval"
  error_message TEXT NOT NULL,
  created_by    UUID REFERENCES users(id),  -- nullable
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State: Refund initiated by admin
CREATE TABLE policy_refund_initiateds (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id                UUID NOT NULL REFERENCES insurance_policies(id),
  stripe_payment_intent_id VARCHAR(255) NOT NULL,
  reason                   TEXT NOT NULL,
  initiated_by             UUID NOT NULL REFERENCES users(id),
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- State: Refund completed
CREATE TABLE policy_refundeds (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id       UUID NOT NULL REFERENCES insurance_policies(id),
  stripe_refund_id VARCHAR(255) NOT NULL,
  amount_refunded NUMERIC(10,2) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.3 Policy State Machine

```
                    [checkout]
                        │
                        ▼
              policy_pending_payment
                        │
                [stripe webhook]
                        │
                        ▼
             policy_payment_received ──────► policy_failed
                        │                        │
              [create contract]                  │ [retry]
                        │                        │
                        ▼                        │
            policy_contract_created ──────► policy_failed
                        │                        │
             [confirm contract]                  │ [retry]
                        │                        │
                        ▼                        │
          policy_contract_confirmed ────► policy_failed
                        │
                 [download PDF]
                        │
                        ▼
               policy_completed

  (from any payment state)
              │
              ▼
    policy_refund_initiated
              │
              ▼
        policy_refunded
```

### 4.4 Team State Tables (3 tables)

```sql
CREATE TABLE team_activateds (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id      UUID NOT NULL REFERENCES teams(id),
  activated_by UUID NOT NULL REFERENCES users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_suspendeds (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id      UUID NOT NULL REFERENCES teams(id),
  reason       TEXT,
  suspended_by UUID NOT NULL REFERENCES users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_archiveds (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id     UUID NOT NULL REFERENCES teams(id),
  reason      TEXT,
  archived_by UUID NOT NULL REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.5 Team Member State Tables (3 tables)

```sql
CREATE TABLE team_member_joineds (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id  UUID NOT NULL REFERENCES team_members(id),
  role       VARCHAR(20) NOT NULL,       -- "owner", "admin", "member"
  joined_via VARCHAR(50) NOT NULL,       -- "created_team" or "accepted_invite"
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_member_role_changeds (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id     UUID NOT NULL REFERENCES team_members(id),
  previous_role VARCHAR(20) NOT NULL,
  new_role      VARCHAR(20) NOT NULL,
  changed_by    UUID NOT NULL REFERENCES users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_member_removeds (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id  UUID NOT NULL REFERENCES team_members(id),
  reason     TEXT,
  removed_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.6 Team Invite State Tables (4 tables)

```sql
CREATE TABLE team_invite_sents (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invite_id     UUID NOT NULL REFERENCES team_invites(id),
  sent_to_email VARCHAR(255) NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_invite_accepteds (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invite_id   UUID NOT NULL REFERENCES team_invites(id),
  accepted_by UUID NOT NULL REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_invite_revokeds (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invite_id  UUID NOT NULL REFERENCES team_invites(id),
  reason     TEXT,
  revoked_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE team_invite_expireds (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invite_id UUID NOT NULL REFERENCES team_invites(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.7 State Resolution Algorithm

To find the **current state** of any entity:

```ruby
# Pseudocode for get_current_policy_state(policy_id)
STATE_TABLES = [
  { name: "policy_refunded",           model: PolicyRefunded,          fk: :policy_id },
  { name: "policy_refund_initiated",   model: PolicyRefundInitiated,   fk: :policy_id },
  { name: "policy_failed",             model: PolicyFailed,            fk: :policy_id },
  { name: "policy_completed",          model: PolicyCompleted,         fk: :policy_id },
  { name: "policy_contract_confirmed", model: PolicyContractConfirmed, fk: :policy_id },
  { name: "policy_contract_created",   model: PolicyContractCreated,   fk: :policy_id },
  { name: "policy_payment_received",   model: PolicyPaymentReceived,   fk: :policy_id },
  { name: "policy_pending_payment",    model: PolicyPendingPayment,    fk: :policy_id },
]

def get_current_state(policy_id)
  latest_record = nil
  latest_name = nil

  STATE_TABLES.each do |entry|
    record = entry[:model].where(entry[:fk] => policy_id).order(created_at: :desc).first
    if record && (latest_record.nil? || record.created_at > latest_record.created_at)
      latest_record = record
      latest_name = entry[:name]
    end
  end

  [latest_name, latest_record]
end
```

**State history** returns ALL records across all state tables, sorted by `created_at` ascending.

**Member role derivation**:
```ruby
def get_member_current_role(member_id)
  state_name, record = get_current_member_state(member_id)
  case state_name
  when "team_member_removed" then nil
  when "team_member_role_changed" then record.new_role
  when "team_member_joined" then record.role
  else nil
  end
end
```

---

## 5. Authentication & Authorization

### 5.1 Password Login

1. Client POSTs `email` + `password` as form-urlencoded to `POST /api/v1/login/access-token`
2. Server looks up user by email
3. **Timing attack prevention**: if user not found, still runs password verification against a dummy hash so response time is constant
4. Password verified using Argon2 (primary) with bcrypt fallback + transparent hash upgrade
5. Returns JWT: `{ access_token: "...", token_type: "bearer" }`

**JWT structure**:
- Algorithm: HS256
- Secret: `SECRET_KEY` env var
- Payload: `{ sub: "<user_uuid>", exp: <unix_timestamp> }`
- Default expiry: 8 days (11520 minutes)

### 5.2 OTP (Passwordless) Login

**Step 1 - Request OTP**: `POST /api/v1/auth/otp/request` with `{ email: "user@example.com" }`
1. Normalize email to lowercase
2. Rate limit: count OTP records for this email in last 15 minutes. If >= 5, silently return success (no new OTP)
3. Generate 6-digit code using `SecureRandom` (each digit independently random 0-9)
4. Hash with SHA-256, store in `otps` table with `expires_at = now + 10 minutes`
5. Send email with the code
6. **Always return generic success** to prevent email enumeration

**Step 2 - Verify OTP**: `POST /api/v1/auth/otp/verify` with `{ email: "...", code: "123456" }`
1. Find most recent unused, non-expired OTP for this email
2. If not found: return 400 "Invalid or expired code"
3. If `attempts >= 5`: return 400 "Too many attempts"
4. Hash submitted code with SHA-256 and compare
5. If mismatch: increment `attempts`, return 400 "Invalid code"
6. On match: set `is_used = true`, find-or-create user by email (passwordless: `hashed_password = NULL`)
7. Return JWT (same format as password login)

### 5.3 Password Recovery

1. `POST /api/v1/password-recovery/{email}` - generates a JWT reset token (48-hour expiry) with `sub: email`, sends email with link `{FRONTEND_HOST}/reset-password?token=...`
2. `POST /api/v1/reset-password/` with `{ token: "...", new_password: "..." }` - verifies JWT, updates password
3. Always returns success even if email not found (prevents enumeration)

### 5.4 Authorization Levels

| Level | How | Used for |
|-------|-----|----------|
| Public | No auth check | Quote, checkout, OTP request/verify, invite accept, health check |
| Authenticated | JWT in `Authorization: Bearer <token>` header | Policies, teams, settings |
| Superuser | Authenticated + `user.is_superuser == true` | User CRUD, failed policies, retry, refund, team suspend/archive |
| Team role | Authenticated + role check via state tables | Team management (owner/admin can invite, owner can change roles) |

### 5.5 Frontend Auth Storage

- JWT stored in `localStorage` under key `"access_token"`
- Sent on every API request via `Authorization: Bearer <token>` header
- `isLoggedIn()` = `localStorage.getItem("access_token") !== null`
- On any 401/403 API response: clear token, hard redirect to `/login`

---

## 6. API Endpoints

All routes prefixed with `/api/v1`.

### 6.1 Auth Routes

| Method | Path | Auth | Request | Response | Notes |
|--------|------|------|---------|----------|-------|
| POST | `/login/access-token` | Public | Form: `username` (=email), `password` | `{ access_token, token_type }` | OAuth2 password grant |
| POST | `/login/test-token` | JWT | - | `UserPublic` | Validates token, returns current user |
| POST | `/password-recovery/{email}` | Public | - | `{ message }` | Sends reset email. Always succeeds |
| POST | `/reset-password/` | Public | `{ token, new_password }` | `{ message }` | Verify JWT reset token, update password |
| POST | `/auth/otp/request` | Public | `{ email }` | `{ message }` | Send 6-digit OTP. Always succeeds |
| POST | `/auth/otp/verify` | Public | `{ email, code }` | `{ access_token, token_type }` | Verify OTP, create user if needed |

### 6.2 User Routes

| Method | Path | Auth | Request | Response | Notes |
|--------|------|------|---------|----------|-------|
| GET | `/users/` | Superuser | `?skip=0&limit=100` | `{ data: [UserPublic], count }` | List all users, ordered by created_at DESC |
| POST | `/users/` | Superuser | `UserCreate` body | `UserPublic` | Admin user creation |
| GET | `/users/me` | JWT | - | `UserPublic` | Current user profile |
| PATCH | `/users/me` | JWT | `{ full_name?, email? }` | `UserPublic` | Update own profile. 409 if email taken |
| PATCH | `/users/me/password` | JWT | `{ current_password, new_password }` | `{ message }` | Verifies current, rejects same password |
| DELETE | `/users/me` | JWT | - | `{ message }` | Self-delete. Blocked for superusers |
| POST | `/users/signup` | Public | `{ email, password, full_name? }` | `UserPublic` | Public registration |
| GET | `/users/{user_id}` | JWT | - | `UserPublic` | Self or superuser only |
| PATCH | `/users/{user_id}` | Superuser | `UserUpdate` body | `UserPublic` | Admin edit |
| DELETE | `/users/{user_id}` | Superuser | - | `{ message }` | Cannot delete self |

**`UserPublic` shape**: `{ id, email, is_active, is_superuser, full_name, created_at }`

### 6.3 Insurance Routes

| Method | Path | Auth | Request | Response | Notes |
|--------|------|------|---------|----------|-------|
| POST | `/insurance/quote` | Public | `QuoteRequest` | `QuoteResponse` | Get price from Insurs API |
| POST | `/insurance/checkout` | Public | `CheckoutRequest` | `{ checkout_url, policy_id }` | Create policy + Stripe session |
| GET | `/insurance/policies` | JWT | `?skip=0&limit=100` | `{ data: [PolicyPublic], count }` | Own + team policies |
| GET | `/insurance/policies/failed` | Superuser | - | `{ data: [PolicyFailed], count }` | All failed policies |
| GET | `/insurance/policies/status` | JWT | - | `{ data: [{policy_id, current_state}], count }` | Bulk status for all accessible policies |
| GET | `/insurance/policies/{id}` | JWT | - | `PolicyDetailResponse` | Full detail + travelers + state history |
| GET | `/insurance/policies/{id}/states` | JWT | - | `PolicyStateResponse` | State timeline only |
| GET | `/insurance/policies/{id}/pdf` | JWT | - | Binary PDF file | Download policy certificate |
| POST | `/insurance/policies/{id}/retry` | Superuser | - | `{ message }` | Re-run fulfillment from current state |
| POST | `/insurance/policies/{id}/refund` | Superuser | `{ reason }` | `{ message }` | Record refund initiation |

**QuoteRequest**:
```json
{
  "start_date": "2024-06-01",
  "end_date": "2024-06-15",
  "departure_country": "US",
  "destination_countries": ["DE", "FR"],
  "coverage_tier": 1,
  "traveler_birth_dates": ["1990-01-15", "1985-03-22"]
}
```

**QuoteResponse**:
```json
{
  "tariff_id": 123,
  "tariff_name": "Standard Travel",
  "price_amount": "45.50",
  "price_currency": "USD",
  "coverage_tier": 1,
  "start_date": "2024-06-01",
  "end_date": "2024-06-15",
  "traveler_count": 2
}
```

**CheckoutRequest**:
```json
{
  "start_date": "2024-06-01",
  "end_date": "2024-06-15",
  "departure_country": "US",
  "destination_countries": ["DE", "FR"],
  "locality_coverage": 237,
  "coverage_tier": 1,
  "travelers": [
    {
      "first_name": "John",
      "last_name": "Doe",
      "birth_date": "1990-01-15",
      "passport_number": "AB1234567",
      "passport_country": "US"
    }
  ],
  "email": "john@example.com",
  "team_id": null
}
```

**Checkout flow logic**:
1. Find or create user by email (no password, OTP-style user)
2. Call Insurs `get_price()` to verify/re-calculate price with exact traveler birth dates
3. Create `InsurancePolicy` record with verified price
4. Create `Traveler` records for each traveler
5. Create Stripe Checkout Session (see Section 7.1)
6. Create `PolicyPendingPayment` state record
7. Return `{ checkout_url, policy_id }`

**PolicyDetailResponse**:
```json
{
  "policy": { /* InsurancePolicyPublic fields */ },
  "travelers": [{ "id": "...", "first_name": "...", "last_name": "...", "birth_date": "...", "passport_number": "...", "passport_country": "..." }],
  "current_state": "policy_completed",
  "state_history": [
    { "state": "policy_pending_payment", "created_at": "...", "details": { "stripe_checkout_session_id": "..." } },
    { "state": "policy_payment_received", "created_at": "...", "details": { "amount_received": "45.50", "currency": "USD" } },
    { "state": "policy_contract_created", "created_at": "...", "details": { "insurs_order_id": "..." } },
    { "state": "policy_contract_confirmed", "created_at": "...", "details": {} },
    { "state": "policy_completed", "created_at": "...", "details": { "pdf_path": "..." } }
  ]
}
```

**Policy access control**: A user can view a policy if they are the `owner_id` OR if they are an active member of the policy's `team_id`.

### 6.4 Stripe Webhook

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| POST | `/stripe/webhook` | Stripe signature | Handles `checkout.session.completed` |

**Logic**:
1. Verify HMAC-SHA256 signature using `STRIPE_WEBHOOK_SECRET`
2. Only handle `checkout.session.completed` events (ignore others, return `{ status: "ignored" }`)
3. Extract `policy_id` from `session.metadata`
4. Create `PolicyPaymentReceived` record with `payment_intent`, `amount_total / 100`, `currency`
5. Call `fulfill_policy()` async (see Section 8)
6. **Always return 200** even if fulfillment fails (failures are recorded in `PolicyFailed` table)

### 6.5 Team Routes

| Method | Path | Auth | Request | Response | Notes |
|--------|------|------|---------|----------|-------|
| GET | `/teams` | JWT | - | `{ data: [TeamPublic], count }` | Teams where user is active member |
| POST | `/teams` | JWT | `{ name }` | `TeamPublic` | Creates team + activates + adds creator as owner |
| GET | `/teams/{id}` | JWT (member) | - | `TeamPublic` | Any active member |
| PATCH | `/teams/{id}` | JWT (owner/admin) | `{ name }` | `TeamPublic` | Update team name only |
| GET | `/teams/{id}/members` | JWT (member) | - | `[TeamMemberDetail]` | Members with derived roles |
| GET | `/teams/{id}/states` | JWT (member) | - | `TeamStateResponse` | Team state timeline |
| POST | `/teams/{id}/suspend` | Superuser | `{ reason? }` | `{ message }` | Creates suspended state |
| POST | `/teams/{id}/archive` | Superuser | `{ reason? }` | `{ message }` | Creates archived state |
| GET | `/teams/{id}/members/{mid}/states` | JWT (owner/admin) | - | `MemberStateResponse` | Member state + role history |
| PATCH | `/teams/{id}/members/{mid}/role` | JWT (owner) | `?role=admin` | `{ message }` | Creates role_changed record |
| DELETE | `/teams/{id}/members/{mid}` | JWT (owner/admin) | - | `{ message }` | Creates member_removed record (soft delete) |
| POST | `/teams/{id}/invites` | JWT (owner/admin) | `{ email, role? }` | `{ message, invite_id }` | Generate token, send email |
| POST | `/teams/{id}/invites/{iid}/revoke` | JWT (owner/admin) | - | `{ message }` | Creates invite_revoked record |
| GET | `/teams/{id}/invites/{iid}/states` | JWT (owner/admin) | - | `InviteStateResponse` | Invite state timeline |
| POST | `/invites/{token}/accept` | Public | - | `{ message, team_id }` | Token-based auth, creates user if needed |

**Team creation logic**:
1. Create `Team` with generated slug
2. Create `TeamActivated` state record
3. Create `TeamMember` for creator
4. Create `TeamMemberJoined` with `role: "owner"`, `joined_via: "created_team"`

**Invite flow**:
1. Generate 32-byte URL-safe random token via `SecureRandom`
2. SHA-256 hash it, store hash in `team_invites.token_hash`
3. Create `TeamInviteSent` state record
4. Send email with link: `{FRONTEND_HOST}/invites/{raw_token}/accept`

**Invite acceptance** (`POST /invites/{token}/accept`):
1. SHA-256 hash the token from URL
2. Look up `TeamInvite` by `token_hash`
3. Check current invite state is `"team_invite_sent"` (reject if accepted/revoked/expired)
4. Find or create user by invite email
5. Create `TeamMember` record
6. Create `TeamMemberJoined` with the invite's role, `joined_via: "accepted_invite"`
7. Create `TeamInviteAccepted` state record

**`TeamMemberDetail` shape**:
```json
{
  "id": "member-uuid",
  "user_id": "user-uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "role": "admin",
  "created_at": "2024-01-15T..."
}
```

### 6.6 Utility Routes

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| GET | `/utils/health-check/` | Public | Returns `true` |
| POST | `/utils/test-email/` | Superuser | Sends test email, `?email_to=...` |

---

## 7. Service Integrations

### 7.1 Stripe

**Used for**: Collecting payments via hosted Checkout Sessions.

**Checkout Session creation parameters**:
```ruby
{
  payment_method_types: ["card"],
  mode: "payment",
  customer_email: email,
  line_items: [{
    price_data: {
      currency: policy.price_currency.downcase,
      product_data: { name: "Travel Insurance Policy" },
      unit_amount: (policy.price_amount * 100).to_i  # cents
    },
    quantity: 1
  }],
  metadata: { policy_id: policy.id.to_s },
  success_url: "#{FRONTEND_HOST}/insurance/confirmation?session_id={CHECKOUT_SESSION_ID}&policy_id=#{policy.id}",
  cancel_url: "#{FRONTEND_HOST}/insurance/checkout"
}
```

**Webhook handling**:
- Endpoint: `POST /api/v1/stripe/webhook`
- Verify signature: `Stripe::Webhook.construct_event(payload, sig_header, STRIPE_WEBHOOK_SECRET)`
- Handle only `checkout.session.completed`
- Extract `policy_id` from `event.data.object.metadata["policy_id"]`
- Record payment: `amount = session.amount_total / 100.0`, `currency = session.currency`
- Trigger fulfillment pipeline

**Refund**: Currently only records a `PolicyRefundInitiated` state. The actual Stripe refund API call is NOT implemented yet.

### 7.2 Insurs.net API

**Base URL**: `https://api.insurs.net/b1`
**Auth**: API key sent as `api_key` field in every JSON request body.

**Fixed constants**:
- `PRODUCT_ID = 1`
- `COMPANY_ID = 366`
- `FRANCHISE_ID = 1`
- Coverage amounts: `{ 1 => 35000, 2 => 100000, 3 => 500000 }` (tier => USD amount)

**All requests are POST with JSON body. All responses are JSON with `{ success: bool, data: {...}, message: "..." }`.**

**Retry policy**: 3 attempts, exponential backoff (2s-10s), only on transport/network errors (not API errors).

#### `POST /get_price`
```json
{
  "api_key": "...",
  "product_id": 1,
  "company_id": 366,
  "franchise_id": 1,
  "departure": "US",
  "arrival": ["DE", "FR"],
  "locality_coverage": [237],
  "date_from": "2024-06-01",
  "date_to": "2024-06-15",
  "coverage_id": 35000,
  "tourists": [{ "birthday": "1990-01-15" }]
}
```
Response: `{ success: true, data: { tariff: [{ tariff_id, tariff_name, price, currency }] } }`

**Quote endpoint uses**: first tariff from response, `locality_coverage` hardcoded to `[237]` (worldwide).

#### `POST /add_contract`
```json
{
  "api_key": "...",
  "product_id": 1,
  "company_id": 366,
  "tariff_id": 0,
  "departure": "US",
  "arrival": ["DE", "FR"],
  "locality_coverage": [237],
  "insurer": {
    "last_name": "Doe", "first_name": "John",
    "birthday": "1990-01-15", "phone": "",
    "passport_number": "AB1234567"
  },
  "tourists": [
    { "last_name": "Doe", "first_name": "John", "birthday": "1990-01-15", "passport_number": "AB1234567" }
  ],
  "params": {
    "date_from": "2024-06-01", "date_to": "2024-06-15",
    "coverage_id": 35000, "franchise_id": 1, "currency_id": 1
  }
}
```
Response: `{ success: true, data: { order_id, police_num, total_amount } }`

**Note**: `tariff_id` is hardcoded to `0` in the fulfillment code.

#### `POST /confirm_contract`
```json
{ "api_key": "...", "order_id": "12345" }
```

#### `POST /get_print_form`
```json
{ "api_key": "...", "order_id": "12345" }
```
Response: Raw PDF binary (not JSON). If error, returns JSON with `success: false`.

#### `POST /cancel_contract`
```json
{ "api_key": "...", "order_id": "12345" }
```

---

## 8. Policy Fulfillment Pipeline

The fulfillment service is an **idempotent state machine** that runs after payment. It reads the current state and resumes from where it left off.

### Pipeline Steps

```
fulfill_policy(policy_id):
  1. Load policy from DB
  2. Get current state via state resolution algorithm
  3. If terminal state (completed, refunded, refund_initiated): return
  4. If failed state: find last non-failed state in history, resume from there
  5. Execute remaining steps in sequence:

  Step 1 (from policy_payment_received):
    → Call insurs_client.add_contract() with policy + traveler data
    → On success: create PolicyContractCreated record, commit
    → On failure: rollback, create PolicyFailed(failed_step: "contract_creation"), commit, raise

  Step 2 (from policy_contract_created):
    → Call insurs_client.confirm_contract(order_id)
    → On success: create PolicyContractConfirmed record, commit
    → On failure: rollback, create PolicyFailed(failed_step: "contract_confirmation"), commit, raise

  Step 3 (from policy_contract_confirmed):
    → Call insurs_client.get_print_form(order_id) → raw PDF bytes
    → Save PDF to disk at {PDF_STORAGE_DIR}/{policy_id}.pdf
    → Create PolicyCompleted(pdf_path: path) record, commit
    → On failure: rollback, create PolicyFailed(failed_step: "pdf_retrieval"), commit, raise
```

### Key Properties
- **Idempotent**: safe to call multiple times; always reads current state first
- **Resumable**: on retry (after failure), finds last good state and resumes
- **Failure recording**: each step catches exceptions, records `PolicyFailed`, then re-raises
- **Triggered by**: Stripe webhook (automatic) or `POST /insurance/policies/{id}/retry` (manual, superuser)

### PDF Storage
- Directory: configurable via `PDF_STORAGE_DIR` (default: `storage/policies/`)
- Filename: `{policy_id}.pdf`
- Served via file download endpoint with `Content-Type: application/pdf`

---

## 9. Email System

### Email Types

| Email | Trigger | Template Variables |
|-------|---------|-------------------|
| OTP code | `POST /auth/otp/request` | `otp_code`, `expire_minutes` |
| Password reset | `POST /password-recovery/{email}` | `link` (with JWT token) |
| New account | `POST /users/` (admin creates user) | `email`, `password`, `link` (login URL) |
| Team invite | `POST /teams/{id}/invites` | `team_name`, `invite_link` |
| Policy confirmation | (not wired yet) | `policy_id`, `start_date`, `end_date`, `link` |
| Test email | `POST /utils/test-email/` | `email`, `link` |

### Implementation
- SMTP transport (TLS on port 587 by default)
- HTML templates using Jinja2 (source in MJML, compiled to HTML)
- Email sending is best-effort: failures don't crash the calling endpoint
- Password reset tokens are JWT with 48-hour expiry, `sub: email`

---

## 10. Frontend Architecture

### Route Structure

Two independent layout groups:

**Authenticated Layout** (`/_layout`) - sidebar + header + main content:
```
/                       Dashboard (welcome message)
/items                  Items CRUD (scaffolding)
/policies               Policy list table with status badges
/policies/:policyId     Policy detail + travelers + state timeline
/teams                  Team cards grid
/teams/:teamId          Team detail (Members tab + Policies tab)
/settings               User profile / password / danger zone tabs
/admin                  User management table (superuser only)
```

**Insurance Funnel Layout** (`/_insurance`) - public, no login, header + step indicator:
```
/insurance              Step 1: Quote form
/insurance/quote        Step 2: Quote review
/insurance/travelers    Step 3: Traveler details
/insurance/checkout     Step 4: Checkout + Stripe redirect
/insurance/confirmation Step 5: Post-payment confirmation
```

**Standalone pages** (auth layout with logo):
```
/login                  Password login form
/otp-login              Two-phase OTP login (email → code)
/signup                 Registration form
/recover-password       Request password reset
/reset-password         Set new password (with token from URL)
```

### Auth Guard
- All `/_layout` routes check `isLoggedIn()` in `beforeLoad` and redirect to `/login`
- `/admin` additionally fetches current user and redirects if not superuser
- Login pages redirect to `/` if already logged in

### State Management
- **Server data**: TanStack Query (no global store)
- **Insurance funnel**: `sessionStorage` under key `"insurance_flow"` (persists across page navigations, cleared on completion)
- **Auth token**: `localStorage` under key `"access_token"`
- **Theme**: `localStorage` under key `"vite-ui-theme"` (light/dark/system)

### UI Component Library
shadcn/ui pattern: Radix UI headless primitives styled with Tailwind CSS utility classes. Components are owned in source (not npm dependency). Key components: Button, Input, PasswordInput, Dialog, Select, Tabs, Table, Badge, Card, Avatar, Skeleton, Sidebar, DropdownMenu, Form (React Hook Form integration).

### Form Pattern
All forms use React Hook Form + Zod validation:
```typescript
const form = useForm({ resolver: zodResolver(schema), mode: "onBlur" })
const mutation = useMutation({
  mutationFn: (data) => Service.method({ requestBody: data }),
  onSuccess: () => { toast("Success"); form.reset() },
  onError: (err) => handleError(err, toast),
  onSettled: () => queryClient.invalidateQueries({ queryKey: [...] })
})
```

### Query Keys
```
["currentUser"]
["items"]
["users"]
["policies"]
["policies", policyId]
["policies", "status"]
["teams"]
["teams", teamId]
["teams", teamId, "members"]
```

---

## 11. Insurance Purchase Flow

### Multi-Step State (sessionStorage)

The insurance funnel stores accumulated data across steps in `sessionStorage`:

```typescript
interface InsuranceFlowData {
  quoteRequest?: {
    start_date: string
    end_date: string
    departure_country: string
    destination_countries: string[]
    coverage_tier: number
    traveler_count: number
    traveler_birth_dates: string[]
  }
  quoteResponse?: {
    tariff_id: number
    tariff_name: string
    price_amount: string
    price_currency: string
    coverage_tier: number
    start_date: string
    end_date: string
    traveler_count: number
  }
  travelers?: Array<{
    first_name: string
    last_name: string
    birth_date: string
    passport_number: string
    passport_country: string
  }>
  email?: string
}
```

Each step reads existing data, adds its piece, and writes back. Each step guards against missing prior-step data by redirecting to `/insurance`.

### Step Details

**Step 1 (Quote Form)**: Date range, departure country, destination countries (multi-select from 195 countries), coverage tier (radio cards: Standard $35k / Advanced $100k / Premium $500k), dynamic traveler birth dates (add/remove).
- Validation: end_date >= start_date
- On submit: call `POST /insurance/quote` API, store request + response

**Step 2 (Quote Review)**: Read-only display of price, dates, countries, tier. Back and Continue buttons.

**Step 3 (Traveler Details)**: N forms (based on `traveler_count`), each with: first name, last name, DOB, passport number, passport country.

**Step 4 (Checkout)**: Order summary, email input. On submit: call `POST /insurance/checkout`, then `window.location.href = checkout_url` (Stripe hosted page).

**Step 5 (Confirmation)**: Receives `?session_id=` and `?policy_id=` from Stripe success redirect. Clears flow data. Shows success + links to sign in.

### Step Indicator
4-step visual progress: Quote → Travelers → Payment → Done. Each step shows number/checkmark based on current position.

### Coverage Tiers (Business Constants)

| Tier | Value | Label (form) | Coverage Limit | Insurs coverage_id |
|------|-------|--------------|----------------|-------------------|
| 1 | 1 | Standard | $35,000 | 35000 |
| 2 | 2 | Advanced | $100,000 | 100000 |
| 3 | 3 | Premium | $500,000 | 500000 |

---

## 12. Configuration & Environment Variables

All configuration comes from environment variables (loaded from `.env` file):

```bash
# App
PROJECT_NAME="Visatile Insurance"
ENVIRONMENT=local                     # local | staging | production
SECRET_KEY=<random-token>            # JWT signing key, MUST change in prod
API_V1_STR=/api/v1
FRONTEND_HOST=http://localhost:5173

# Database
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<password>
POSTGRES_DB=visatile

# Auth
ACCESS_TOKEN_EXPIRE_MINUTES=11520     # 8 days

# OTP
OTP_EXPIRE_MINUTES=10
OTP_LENGTH=6
OTP_MAX_ATTEMPTS=5
OTP_RATE_LIMIT_MINUTES=15

# Insurs API
INSURS_API_BASE_URL=https://api.insurs.net/b1
INSURS_API_KEY=<api-key>

# Stripe
STRIPE_SECRET_KEY=<sk_...>
STRIPE_PUBLISHABLE_KEY=<pk_...>
STRIPE_WEBHOOK_SECRET=<whsec_...>

# PDF Storage
PDF_STORAGE_DIR=storage/policies

# Email (SMTP)
SMTP_TLS=true
SMTP_PORT=587
SMTP_HOST=<smtp-host>
SMTP_USER=<smtp-user>
SMTP_PASSWORD=<smtp-password>
EMAILS_FROM_EMAIL=noreply@example.com
EMAILS_FROM_NAME="Visatile Insurance"
EMAIL_RESET_TOKEN_EXPIRE_HOURS=48

# Superuser bootstrap (first run)
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=<password>

# Error tracking
SENTRY_DSN=<sentry-dsn>              # optional

# CORS
BACKEND_CORS_ORIGINS=http://localhost:5173
```

**Security validations**: In staging/production, `SECRET_KEY`, `POSTGRES_PASSWORD`, and `FIRST_SUPERUSER_PASSWORD` must not equal `"changethis"`.

**DB initialization**: On first run, creates the superuser defined by `FIRST_SUPERUSER` / `FIRST_SUPERUSER_PASSWORD` if not already present.

---

## 13. Rails Implementation Guidance

### 13.1 Recommended Gems

```ruby
# Gemfile
gem "bcrypt"              # Password hashing (has_secure_password)
gem "jwt"                 # JWT token creation/verification
gem "stripe"              # Stripe API client
gem "faraday"             # HTTP client for Insurs API
gem "faraday-retry"       # Retry middleware
gem "action_mailer"       # Email (built-in)
gem "jbuilder"            # JSON serialization (or blueprinter-rb)
gem "rack-cors"           # CORS support
```

### 13.2 Model Structure

```ruby
# Core models
class User < ApplicationRecord
  has_secure_password validations: false  # Allow nil password for OTP users
  has_many :items, dependent: :destroy
  has_many :insurance_policies, foreign_key: :owner_id
  has_many :team_memberships, class_name: "TeamMember"
end

class InsurancePolicy < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :team, optional: true
  has_many :travelers, dependent: :destroy

  # State queries delegated to PolicyStateService
  def current_state
    PolicyStateService.current_state(id)
  end

  def state_history
    PolicyStateService.state_history(id)
  end
end

class Traveler < ApplicationRecord
  belongs_to :insurance_policy
end

class Team < ApplicationRecord
  has_many :members, class_name: "TeamMember", dependent: :destroy
  has_many :invites, class_name: "TeamInvite", dependent: :destroy
end

class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user

  def current_role
    TeamMemberStateService.current_role(id)
  end
end

class TeamInvite < ApplicationRecord
  belongs_to :team
  belongs_to :inviter, class_name: "User", foreign_key: :invited_by
end

class Otp < ApplicationRecord
  # No associations needed
end
```

### 13.3 State Table Models

Create a base concern for state models:

```ruby
module PolicyState
  extend ActiveSupport::Concern
  included do
    belongs_to :insurance_policy, foreign_key: :policy_id
  end
end

class PolicyPendingPayment < ApplicationRecord
  include PolicyState
end

class PolicyPaymentReceived < ApplicationRecord
  include PolicyState
end

# ... same for all 8 policy state models
# ... same pattern for team/member/invite state models
```

### 13.4 State Service

```ruby
class PolicyStateService
  TABLES = [
    { name: "policy_refunded", model: PolicyRefunded, fk: :policy_id },
    { name: "policy_refund_initiated", model: PolicyRefundInitiated, fk: :policy_id },
    { name: "policy_failed", model: PolicyFailed, fk: :policy_id },
    { name: "policy_completed", model: PolicyCompleted, fk: :policy_id },
    { name: "policy_contract_confirmed", model: PolicyContractConfirmed, fk: :policy_id },
    { name: "policy_contract_created", model: PolicyContractCreated, fk: :policy_id },
    { name: "policy_payment_received", model: PolicyPaymentReceived, fk: :policy_id },
    { name: "policy_pending_payment", model: PolicyPendingPayment, fk: :policy_id },
  ]

  def self.current_state(policy_id)
    latest = nil
    latest_name = nil

    TABLES.each do |entry|
      record = entry[:model].where(entry[:fk] => policy_id).order(created_at: :desc).first
      if record && (latest.nil? || record.created_at > latest.created_at)
        latest = record
        latest_name = entry[:name]
      end
    end

    latest_name ? [latest_name, latest] : nil
  end

  def self.state_history(policy_id)
    records = TABLES.flat_map do |entry|
      entry[:model].where(entry[:fk] => policy_id).map { |r| [entry[:name], r] }
    end
    records.sort_by { |_name, record| record.created_at }
  end
end
```

### 13.5 Fulfillment Service (Background Job)

```ruby
class PolicyFulfillmentJob < ApplicationJob
  queue_as :default

  def perform(policy_id)
    policy = InsurancePolicy.find(policy_id)
    state_name, state_record = PolicyStateService.current_state(policy_id)

    return if %w[policy_completed policy_refunded policy_refund_initiated].include?(state_name)

    # Resume from last good state on failure
    if state_name == "policy_failed"
      history = PolicyStateService.state_history(policy_id)
      last_good = history.reject { |name, _| name == "policy_failed" }.last
      return unless last_good
      state_name, state_record = last_good
    end

    client = InsursClient.new

    if state_name == "policy_payment_received"
      create_contract(policy, client)
      state_name, state_record = PolicyStateService.current_state(policy_id)
    end

    if state_name == "policy_contract_created"
      confirm_contract(policy, state_record, client)
      state_name, state_record = PolicyStateService.current_state(policy_id)
    end

    if state_name == "policy_contract_confirmed"
      download_pdf(policy, state_record, client)
    end
  end

  private

  def create_contract(policy, client)
    # ... call client.add_contract, create PolicyContractCreated record
    # ... on failure: create PolicyFailed(failed_step: "contract_creation"), raise
  end

  def confirm_contract(policy, state_record, client)
    # ... call client.confirm_contract, create PolicyContractConfirmed record
    # ... on failure: create PolicyFailed(failed_step: "contract_confirmation"), raise
  end

  def download_pdf(policy, state_record, client)
    # ... call client.get_print_form, save to disk, create PolicyCompleted record
    # ... on failure: create PolicyFailed(failed_step: "pdf_retrieval"), raise
  end
end
```

### 13.6 Controller Structure

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "login/access-token", to: "auth#login"
      post "login/test-token", to: "auth#test_token"
      post "password-recovery/:email", to: "auth#recover_password"
      post "reset-password", to: "auth#reset_password"

      namespace :auth do
        post "otp/request", to: "otp#request_code"
        post "otp/verify", to: "otp#verify_code"
      end

      resources :users, only: [:index, :create, :show, :update, :destroy] do
        collection do
          get :me, to: "users#me"
          patch :me, to: "users#update_me"
          patch "me/password", to: "users#update_password"
          delete :me, to: "users#destroy_me"
          post :signup, to: "users#signup"
        end
      end

      namespace :insurance do
        post :quote
        post :checkout
        resources :policies, only: [:index, :show] do
          collection do
            get :failed
            get :status
          end
          member do
            get :states
            get :pdf
            post :retry
            post :refund
          end
        end
      end

      post "stripe/webhook", to: "stripe_webhooks#create"

      resources :teams, only: [:index, :create, :show, :update] do
        member do
          get :states
          post :suspend
          post :archive
        end
        resources :members, only: [:index, :destroy], controller: "team_members" do
          member do
            get :states
            patch :role
          end
        end
        resources :invites, only: [:create], controller: "team_invites" do
          member do
            post :revoke
            get :states
          end
        end
      end

      post "invites/:token/accept", to: "team_invites#accept"

      get "utils/health-check", to: "utils#health_check"
    end
  end
end
```

### 13.7 Authentication Concern

```ruby
module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate!
    token = request.headers["Authorization"]&.split("Bearer ")&.last
    raise UnauthorizedError unless token

    payload = JWT.decode(token, ENV["SECRET_KEY"], true, algorithm: "HS256").first
    @current_user = User.find(payload["sub"])
    raise ForbiddenError unless @current_user.is_active
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    raise UnauthorizedError
  end

  def require_superuser!
    authenticate!
    raise ForbiddenError unless @current_user.is_superuser
  end

  def current_user
    @current_user
  end
end
```

### 13.8 Key Business Rules

1. **Timing-safe auth**: When user not found during password login, still run bcrypt verification against a dummy hash to prevent timing attacks
2. **Email enumeration prevention**: OTP request and password recovery always return success regardless of whether the email exists
3. **OTP rate limiting**: Max 5 OTPs per email per 15 minutes, max 5 verification attempts per OTP
4. **Team member soft delete**: Removing a member creates a `TeamMemberRemoved` record rather than deleting the `TeamMember` row
5. **Invite token security**: Raw token travels in email, SHA-256 hash stored in DB. On acceptance, hash the incoming token and look up by hash
6. **Policy access**: Users can see their own policies PLUS all policies belonging to teams they're active members of
7. **Webhook resilience**: Stripe webhook always returns 200. Fulfillment failures are recorded but don't fail the webhook
8. **PDF storage**: Local filesystem (needs persistent volume or migration to S3 for production)
9. **Coverage tier display labels**: Tier 1 = "Standard", Tier 2 = "Advanced", Tier 3 = "Premium" (with coverage limits $35k, $100k, $500k respectively)
10. **Superuser bootstrap**: On app startup, create the first superuser from env vars if not present
