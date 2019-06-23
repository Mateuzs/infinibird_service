# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :infinibird_service, key: :value

#  Configures the endpoint

config :infinibird_service, InfinibirdService.Endpoint,
load_from_system_env: true,
server: true,
secret_key_base: "${SECRET_KEY_BASE}",
url: [scheme: "https", host: "infinibird-service.gigalixirapp.com", port: 443],
cache_static_manifest: "priv/static/cache_manifest.json"
force_ssl: [rewrite_on: [:x_forwarded_proto], hsts: true, host: nil],


config :infinibird_service,
  infinibird_service_basic_auth_config: [
    username: "c3VwZXJfc2VjcmV0X3VzZXI=",
    password: "cGFzc3dvcmRfc3VwZXJfc2VjcmV0",
    realm: "Infinibird Area"
  ]

# and access this configuration in your application as:
#
#     Application.get_env(:infinibird_service, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
