defmodule InfinibirdDB.User do
  use Ecto.Schema

  @primary_key {:device_id, :string, []}
  schema "users" do
    field(:token, :string)
    field(:password, :string)

    has_many(:ride_metrics, InfinibirdDB.RideMetrics,
      references: :device_id,
      foreign_key: :device_id
    )
  end
end
