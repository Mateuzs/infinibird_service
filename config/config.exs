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
  url: [host: "localhost"],
  render_errors: [view: InfinibirdWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Infinibird.PubSub, adapter: Phoenix.PubSub.PG2]

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

#config Ecto repos
config :infinibird_service, ecto_repos: [Infinibird.Repo]

