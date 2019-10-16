use Mix.Config

config :infinibird_service, InfinibirdService.Endpoint,
  load_from_system_env: true,
  server: true,
  secret_key_base: "${SECRET_KEY_BASE}",
  url: [scheme: "https", host: "infinibird-service.gigalixirapp.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :infinibird_service, InfinibirdService.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections.
  pool_size: 2

# Do not print debug messages in production
config :logger, level: :info

config :infinibird_service, InfinibirdService.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto], hsts: true, host: nil]

# DB config
config :infinibird_service, InfinibirdDB.Repo,
  username: "b0ca5494-639d-4076-9597-fadfdffe61d8-user",
  password: "pw-75c51fb8-61f6-4815-af31-57f841ccb809@postgres-free-tier-1",
  database: "b0ca5494-639d-4076-9597-fadfdffe61d8",
  hostname: "gigalixir.com",
  pool_size: 10
