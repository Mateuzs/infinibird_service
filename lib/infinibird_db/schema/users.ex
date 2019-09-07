defmodule InfinibirdDB.Users do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:device_id, :string, primary_key: true)
    field(:token, :string)

    has_many(:ride_metrics, InfinibirdDB.RideMetrics)
  end
end
