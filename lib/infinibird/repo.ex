defmodule Infinibird.Repo do
  use Ecto.Repo,
    otp_app: :infinibird_service,
    adapter: Ecto.Adapters.Postgres
end
