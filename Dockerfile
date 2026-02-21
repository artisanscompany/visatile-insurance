# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

ARG RUBY_VERSION=3.4.2
ARG NODE_VERSION=20.18.1

# Stage 1: Get Node.js from official image
FROM node:${NODE_VERSION}-slim AS node

# Stage 2: Base Ruby image
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

# Copy Node.js from official image (faster than installing)
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Install base packages with BuildKit cache mount
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libjemalloc2 \
        libvips \
        postgresql-client \
        git

# Stage 3: Build stage
FROM base AS build

# Install build packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libyaml-dev \
        pkg-config

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./

# Install gems with cache mount (Git config + bundle install in same RUN)
RUN --mount=type=cache,target=/usr/local/bundle/cache,sharing=locked \
    git config --global url."https://github.com/".insteadOf git@github.com: && \
    git config --global url."https://".insteadOf git:// && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy package files and install npm dependencies
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm ci

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Build Vite assets
RUN npm run build

# Precompile assets with dummy SECRET_KEY_BASE
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Stage 4: Final production image
FROM base

# Copy built artifacts from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-privileged user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Environment variables for Thruster
ENV THRUSTER_HTTP_PORT=80 \
    THRUSTER_TARGET_PORT=3000

# Expose port 80 for Traefik routing
EXPOSE 80

# Start server via Thruster
CMD ["./bin/thrust", "./bin/rails", "server"]
