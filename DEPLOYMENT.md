# Deploying to Coolify

## Infrastructure

- **Coolify**: paas.gitgar.com
- **Server**: hetzner-ax41-main-production
- **Domain**: travelskit.com (Cloudflare DNS)
- **Database**: PostgreSQL 18 (ofdecks-postgres, port 5433 public)
- **Build**: Dockerfile (multi-stage, Thruster on port 80)

## Quick Deploy

Code changes are deployed by pushing to `main` and clicking **Redeploy** on Coolify. If the build is cached, use **Advanced > Force deploy (without cache)**.

## Environment Variables

Set in Coolify > Configuration > Environment Variables. Required:

| Variable | Source |
|----------|--------|
| `RAILS_ENV` | `production` |
| `DATABASE_URL` | Coolify Postgres internal URL |
| `SECRET_KEY_BASE` | `openssl rand -hex 64` |
| `RAILS_MASTER_KEY` | `openssl rand -hex 16` |
| `RAILS_SERVE_STATIC_FILES` | `true` |
| `RAILS_LOG_TO_STDOUT` | `true` |
| `APP_DOMAIN` | `travelskit.com` |
| `STRIPE_*` | From Stripe dashboard |
| `POSTMARK_*` | From Postmark dashboard |
| `INSURS_ONLINE_*` | From Insurs API |
| `CLOUDFLARE_R2_*` | From Cloudflare R2 dashboard |

## Database Config

Production uses a single PostgreSQL database with multi-database config for Solid Queue/Cache/Cable. All point to the same `DATABASE_URL` — see `config/database.yml`.

## DNS (Cloudflare)

If the domain doesn't resolve, go to [dash.cloudflare.com](https://dash.cloudflare.com), select the domain, and add an **A record** pointing to the server IP. Enable proxy (orange cloud) for SSL.

## Debugging

Check **Logs** tab in Coolify for runtime errors. Common issues:

- **`queue` database not configured** — ensure `database.yml` has `queue:`, `cache:`, `cable:` entries under production
- **App restart loop** — read logs for the actual error, fix, push, force redeploy
- **502 Bad Gateway** — verify port 80 in Coolify config (Thruster serves on 80)
- **Asset issues** — ensure `RAILS_SERVE_STATIC_FILES=true` and Vite builds in Dockerfile
