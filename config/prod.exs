config :infinibird_service, InfinibirdService.Endpoint,
  server: true,
  url: [scheme: "https", host: "infinibird-service.gigalixirapp.com", port: 443],
  http: [compress: true, port: 80],
  https: [
    compress: true,
    port: 443,
    force_ssl: [hsts: true],
    otp_app: :infinibird_service
  ],
  cache_static_manifest: "priv/static/manifest.json"

config :infinibird_service, InfinibirdService.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections.
  pool_size: 2

# Do not print debug messages in production
config :logger, level: :info
