# frozen_string_literal: true

class AccountSlugExtractor
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    path = request.path_info

    # Skip for static assets and health checks
    return @app.call(env) if skip_extraction?(path)

    # Extract account slug from the first path segment
    # e.g., /my-account/posts -> slug = "my-account"
    if (match = path.match(%r{^/([a-z0-9-]+)(?:/|$)}i))
      slug = match[1]

      # Don't treat known routes as account slugs
      unless reserved_path?(slug)
        if (account = Account.find_by(slug: slug))
          Current.account = account
        end
      end
    end

    @app.call(env)
  end

  private

  def skip_extraction?(path)
    path.start_with?('/assets', '/vite-dev', '/vite-test', '/up', '/__vite')
  end

  def reserved_path?(slug)
    # List of paths that are not account slugs
    %w[
      session
      sessions
      registration
      registrations
      accounts
      invites
      posts
      up
      rails
      assets
      vite-dev
      vite-test
    ].include?(slug.downcase)
  end
end
