config :infinibird_service, InfinibirdService.Endpoint,
  load_from_system_env: true,
  # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
  http: [port: {:system, "PORT"}],
  # Without this line, your app will not start the web server!
  server: true,
  secret_key_base: "${SECRET_KEY_BASE}",
  url: [host: "infinibird-service.gigalixirapp.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :infinibird_service, InfinibirdService.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections.
  pool_size: 2

# Do not print debug messages in production
config :logger, level: :info

config :infinibird, InfinibirdWeb.Endpoint, force_ssl: [rewrite_on: [:x_forwarded_proto]]
