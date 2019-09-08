defmodule InfinibirdDB.User do
  use Ecto.Schema

  @primary_key {:device_id, :string, []}
  schema "users" do
    field(:token, :string)

    has_many(:ride_metrics, InfinibirdDB.RideMetrics)
  end
end
