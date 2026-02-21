# AssetMaker

A Rails application for asset management.

## Requirements

* Ruby 3.4.2
* PostgreSQL
* Node.js 20.x

## Setup

```bash
# Install dependencies
bundle install
npm install

# Setup database
bin/rails db:create db:migrate

# Start the server
bin/dev
```

## Deployment

This application is configured for deployment on Coolify with Docker. See `COOLIFY_DEPLOYMENT_GUIDE.md` for details.
